
-- Téma: Fotbalová liga
-- Autor: Zuzana Bohatová
-- v tomto scriptu najdete triggers, views, indexy a procedury.

-- Nejprve je nutné spustit soubor Tabulky.sql

-- INDEXY
 
CREATE INDEX Tym_stadion_jmeno_inx ON Tym (stadion_jmeno);

CREATE INDEX Zapas_rozhodci_id_inx ON Zapas (rozhodci_id);

CREATE INDEX Zapas_hoste_inx ON Zapas (hoste);

CREATE INDEX Zapas_domaci_inx ON Zapas (domaci);

CREATE INDEX Trener_tym_jmeno_inx ON Trener (tym_jmeno);

CREATE INDEX Trener_jmeno_inx ON Trener (jmeno);

CREATE INDEX Hrac_tym_jmeno_inx ON Hrac (tym_jmeno);

CREATE INDEX HracHraje_zapas_id_inx ON HracHraje (zapas_id);

CREATE INDEX HracScoruje_minuta_inx ON HracScoruje (minuta);

CREATE INDEX HracScoruje_zapas_id_inx ON HracScoruje (zapas_id);


-- VIEWS

-- Zobrazení tymu spolu s poètem jeho trenérù a jejich jmeny, a adresou stadionu 
CREATE VIEW tym_vw AS
    SELECT
        T.jmeno         AS tym_jmeno,
        T.pocet_vyher,
        T.pocet_proher,
        T.pocet_remiz,
        T.pocet_bodu,
        T.goly_dal,
        T.goly_dostal,
        TR.jmeno        AS trener_jmeno,
        TR.narodnost    AS trener_narodnost,
        TR.vek          AS trener_vek,
        S.jmeno         AS stadion_jmeno,
        S.kapacita      AS stadion_kapacita,
        S.ulice         AS stadion_ulice,
        S.cislo_popisne AS stadion_cislo_popisne,
        S.mesto         AS stadion_mesto,
        S.psc           AS stadion_psc,
        S.zeme          AS stadion_zeme
    FROM
        Tym     T
        LEFT JOIN Trener  TR ON T.jmeno = TR.tym_jmeno
        LEFT JOIN Stadion S ON T.stadion_jmeno = S.jmeno
    ORDER BY T.pocet_bodu DESC, (T.goly_dal - T.goly_dostal) DESC;

-- View pro zobrazení zápasu spolu s jménem jeho rozhodèí a adresou stadionu 
CREATE VIEW zapasy_info_vw AS
    SELECT
        Z.zapas_id,
        TO_CHAR(Z.datum, 'DD-MM-RRRR HH24:MI') AS datum_zapasu, 
        Z.domaci,
        Z.hoste,
        Z.goly_domaci,
        Z.goly_hoste,
        Z.dohrano,
        Z.vitez,
        R.jmeno         AS rozhodci_jmeno,
        S.jmeno         AS stadion_jmeno,
        S.kapacita      AS stadion_kapacita,
        S.ulice         AS stadion_ulice,
        S.cislo_popisne AS stadion_cislo_popisne,
        S.mesto         AS stadion_mesto,
        S.psc           AS stadion_psc,
        S.zeme          AS stadion_zeme
    FROM
        Zapas    Z
        LEFT JOIN Rozhodci R ON Z.rozhodci_id = R.rozhodci_id
        LEFT JOIN stadion  S ON Z.stadion_jmeno = S.jmeno
    ORDER BY Z.datum ASC;

-- View pro  hráèe - poèet zápasù, gólù, prùmìrný poèet golù na zápas
CREATE VIEW hrac_statistika_vw AS
    SELECT
        H.hrac_id,
        H.jmeno,
        H.vek,
        H.pozice,
        H.narodnost,
        H.pocet_golu,
        H.tym_jmeno,
        COALESCE(Statistiky.pocet_zapasu, 0) AS pocet_zapasu,
        CASE
            WHEN COALESCE(Statistiky.pocet_zapasu, 0) > 0 THEN CAST(H.pocet_golu AS FLOAT) / COALESCE(Statistiky.pocet_zapasu, 1)
            ELSE 0
        END AS prumer_golu_na_zapas
    FROM
        Hrac H
        LEFT JOIN (
            SELECT
                hrac_id,
                COUNT(zapas_id) AS pocet_zapasu
            FROM HracHraje
            GROUP BY hrac_id
        ) Statistiky ON H.hrac_id = Statistiky.hrac_id;


-- View na dvojice hráè zápas s dodateènými informacemi o hráèi a zápase
CREATE VIEW hracHraje_vw AS
    SELECT
        H.hrac_id,
        H.jmeno AS hrac_jmeno,
        H.vek AS hrac_vek,
        H.pozice AS hrac_pozice,
        H.narodnost AS hrac_narodnost,
        H.tym_jmeno AS hrac_tym,
        Z.zapas_id AS zapas_id,
        TO_CHAR(Z.datum, 'DD-MM-RRRR HH24:MI') AS datum_zapasu,        
        Z.domaci AS tym_domaci,
        Z.hoste AS tym_hoste,
        Z.vitez AS vitez
    FROM
        Hrac H
        JOIN HracHraje HH ON H.hrac_id = HH.hrac_id
        JOIN Zapas Z ON HH.zapas_id = Z.zapas_id;
    
-- View pro zobrazení informací o hráèi, který scóroval v zápase a plus dodateèné informace o zápase
CREATE VIEW hracScoruje_vw AS
    SELECT
        H.hrac_id,
        H.jmeno AS hrac_jmeno,
        H.vek AS hrac_vek,
        H.pozice AS hrac_pozice,
        H.narodnost AS hrac_narodnost,
        H.pocet_golu AS hrac_celkem_golu_za_sezonu,
        H.tym_jmeno AS hrac_tym,
        HS.minuta AS minuta,
        Z.zapas_id AS zapas_id,
        TO_CHAR(Z.datum, 'DD-MM-RRRR HH24:MI') AS datum_zapasu, 
        Z.domaci AS tym_domaci,
        Z.hoste AS tym_hoste,
        Z.vitez AS vitez
    FROM
        Hrac H
        JOIN HracScoruje HS ON H.hrac_id = HS.hrac_id
        JOIN Zapas Z ON HS.zapas_id = Z.zapas_id;

-- Tabulka tymù seøazených podle poøadí v lize
CREATE VIEW tabulka_tymu_vw AS 
    SELECT *
    FROM Tym
    ORDER BY pocet_bodu DESC, (goly_dal - goly_dostal) DESC;
    
-- Tabulka hráèù podle poètu vstøelených gólù
CREATE VIEW nejlepsi_strelec_vw AS 
    SELECT *       
    FROM Hrac
    ORDER BY pocet_golu DESC;
        
-- TRIGGERS

-- Trigger, který aktualizuje statistiky každého týmu po dohraném zápase
CREATE OR REPLACE TRIGGER update_tymu_po_dohranem_zapasu
AFTER INSERT OR UPDATE OF dohrano ON Zapas
FOR EACH ROW
WHEN (new.dohrano = 1)
DECLARE
    v_domaci_tym VARCHAR2(255) := :new.domaci;
    v_hoste_tym VARCHAR2(255) := :new.hoste;
BEGIN
    IF :new.goly_domaci > :new.goly_hoste THEN
        -- Vítìzství domácího týmu
        UPDATE Tym
        SET pocet_bodu = pocet_bodu + 3,
            pocet_vyher = pocet_vyher + 1,
            goly_dal = goly_dal + :new.goly_domaci,
            goly_dostal = goly_dostal + :new.goly_hoste
        WHERE jmeno = v_domaci_tym;

        UPDATE Tym
        SET pocet_proher = pocet_proher + 1,
            goly_dal = goly_dal + :new.goly_hoste,
            goly_dostal = goly_dostal + :new.goly_domaci
        WHERE jmeno = v_hoste_tym;
    ELSIF :new.goly_domaci < :new.goly_hoste THEN
        -- Vítìzství hostujícího týmu
        UPDATE Tym
        SET pocet_bodu = pocet_bodu + 3,
            pocet_vyher = pocet_vyher + 1,
            goly_dal = goly_dal + :new.goly_hoste,
            goly_dostal = goly_dostal + :new.goly_domaci
        WHERE jmeno = v_hoste_tym;

        UPDATE Tym
        SET pocet_proher = pocet_proher + 1,
            goly_dal = goly_dal + :new.goly_domaci,
            goly_dostal = goly_dostal + :new.goly_hoste
        WHERE jmeno = v_domaci_tym;
    ELSE
        -- Remíza
        UPDATE Tym
        SET pocet_bodu = pocet_bodu + 1,
            pocet_remiz = pocet_remiz + 1,
            goly_dal = goly_dal + :new.goly_domaci,
            goly_dostal = goly_dostal + :new.goly_hoste
        WHERE jmeno IN (v_domaci_tym, v_hoste_tym);
    END IF;
END;
/

-- Trigger zvýší hráèi poèet gólù, pokud v zápase scóroval 
CREATE OR REPLACE TRIGGER pridej_gol_scorujicimu_hraci
AFTER INSERT ON HracScoruje
FOR EACH ROW
BEGIN
    UPDATE Hrac
    SET pocet_golu = pocet_golu + 1
    WHERE hrac_id = :new.hrac_id;
END;
/

-- Trigger, který kontroluje, že domácí a hosté nejsou stejný tým
CREATE OR REPLACE TRIGGER hoste_domaci_nejsou_stejny_tym
BEFORE INSERT OR UPDATE OF domaci, hoste ON Zapas
FOR EACH ROW
BEGIN
    IF :NEW.domaci = :NEW.hoste THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Domácí a hosté nemohou být stejný tým.');
    END IF;
END;
/

-- Trigger, který kontroluje, že vítìz zápasu odpovídá buï domácím, hostùm nebo null
CREATE OR REPLACE TRIGGER vitez_hral_zapas
BEFORE INSERT OR UPDATE OF vitez ON Zapas
FOR EACH ROW
BEGIN
    IF :NEW.vitez IS NOT NULL AND :NEW.vitez NOT IN (:NEW.domaci, :NEW.hoste) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: Hodnota ve sloupci "vitez" musí odpovídat týmu domácích, týmu hostù nebo být NULL.');
    END IF;
END;
/

-- Trigger hlídá, že tým za který hraje hráè daný zápas hrál
CREATE OR REPLACE TRIGGER hracuv_tym_hral_zapas
BEFORE INSERT OR UPDATE ON HracHraje
FOR EACH ROW
DECLARE
    v_domaci VARCHAR2(255);
    v_hoste VARCHAR2(255);
    v_tym_hrace VARCHAR2(255);
BEGIN
    SELECT domaci, hoste INTO v_domaci, v_hoste
    FROM Zapas
    WHERE zapas_id = :NEW.zapas_id;
    
    SELECT tym_jmeno INTO v_tym_hrace
    FROM Hrac 
    WHERE hrac_id = :NEW.hrac_id;
    
    IF v_tym_hrace NOT IN (v_domaci, v_hoste) THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error: Hráè nemùže hrát zápas, protože jeho tým daný zápas nehrál.');
    END IF;
END;
/

-- Trigger hlídá, že tým za který hráè scóroval daný zápas hrál
CREATE OR REPLACE TRIGGER tym_scorujiciho_hrace_hral_zapas
BEFORE INSERT OR UPDATE ON HracScoruje
FOR EACH ROW
DECLARE
    v_domaci VARCHAR2(255);
    v_hoste VARCHAR2(255);
    v_tym_hrace VARCHAR2(255);
BEGIN
    SELECT domaci, hoste INTO v_domaci, v_hoste
    FROM Zapas
    WHERE zapas_id = :NEW.zapas_id;
    
    SELECT tym_jmeno INTO v_tym_hrace
    FROM Hrac 
    WHERE hrac_id = :NEW.hrac_id;
    
    IF v_tym_hrace NOT IN (v_domaci,v_hoste) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Error: Hráè nemùže hrát zápas, protože jeho tým daný zápas nehrál.');
    END IF;
END;
/

-- Trigger, který hlídá, že pokud je už zápas dohraný, tak datum zápasu je starší než aktuální datum, má rozhodèího a stadion
CREATE OR REPLACE TRIGGER zapas_muze_byt_dohrany
BEFORE INSERT OR UPDATE OF dohrano ON Zapas
FOR EACH ROW
DECLARE
    v_current_date TIMESTAMP;
BEGIN
    IF :NEW.dohrano = 1 THEN
        SELECT CURRENT_TIMESTAMP INTO v_current_date FROM DUAL;
        IF :NEW.datum >= v_current_date THEN
            RAISE_APPLICATION_ERROR(-20005, 'Error: Zápas ještì nemùže být dohraný, jelikož èas a datum zápasu ještì nebylo.');
        END IF;

        IF :NEW.rozhodci_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20006, 'Error: Zápas je dohrán, ale není pøiøazen rozhodèí.');
        END IF;

        IF :NEW.stadion_jmeno IS NULL THEN
            RAISE_APPLICATION_ERROR(-20007, 'Error: Zápas je dohrán, ale není pøiøazen stadion.');
        END IF;
    END IF;
END;
/

-- Trigger zakazuje smazat zápas, pokud oba týmy stále existují 
CREATE OR REPLACE TRIGGER zapas_zakaz_smazani
BEFORE DELETE ON Zapas
FOR EACH ROW
DECLARE
    v_dohrano NUMERIC(1,0) := :OLD.dohrano;
    v_domaci_tym_existuje NUMERIC(1,0);
    v_hoste_tym_existuje NUMERIC(1,0);
BEGIN

    IF v_dohrano = 1 THEN
        -- Zkontrolujeme, zda existuje domácí tým
        SELECT COUNT(*) INTO v_domaci_tym_existuje
        FROM Tym
        WHERE jmeno = :OLD.domaci;

        -- Zkontrolujeme, zda existuje hostující tým
        SELECT COUNT(*) INTO v_hoste_tym_existuje
        FROM Tym
        WHERE jmeno = :OLD.hoste;

        -- Pokud oba týmy existují, vyhodíme chybu, která zabrání smazání zápasu
        IF v_domaci_tym_existuje = 1 AND v_hoste_tym_existuje = 1 THEN
            RAISE_APPLICATION_ERROR(-20008, 'Error: Nelze smazat zápas. Zápas je dohraný a oba týmy stále existují.');
        END IF;
    END IF;
END;
/

-- Trigger kotrolující správnì urèeného vítìze podle padlých golu
CREATE OR REPLACE TRIGGER urci_viteze_zapasu
BEFORE INSERT OR UPDATE ON Zapas
FOR EACH ROW
BEGIN
    IF :NEW.goly_domaci > :NEW.goly_hoste THEN
        :NEW.vitez := :NEW.domaci;
    ELSIF :NEW.goly_domaci < :NEW.goly_hoste THEN
        :NEW.vitez := :NEW.hoste;
    ELSE
        :NEW.vitez := NULL; -- Remíza
    END IF;
END;
/

-- Trigger, který pøiète rozhodèímu odpískaný zápas
CREATE OR REPLACE TRIGGER pricti_rozhodcimu_odpiskany_zapas
AFTER INSERT OR UPDATE ON Zapas
FOR EACH ROW
DECLARE
    v_rozhodci_id NUMERIC(6, 0);
BEGIN
    -- Zkontrolujte, zda zápas byl dohraný (dohrano = 1) a má pøiøazeného rozhodèího
    IF :NEW.dohrano = 1 AND :NEW.rozhodci_id IS NOT NULL THEN
        -- Získat ID rozhodèího ze zápasu
        v_rozhodci_id := :NEW.rozhodci_id;

        -- Zvýšení poètu odpískaných zápasù pro daného rozhodèího
        UPDATE Rozhodci
        SET pocet_odpiskanych_zapasu = pocet_odpiskanych_zapasu + 1
        WHERE rozhodci_id = v_rozhodci_id;
    END IF;
END;
/


-- PROCEDURY

-- Procedura, která vloží nového hráèe

CREATE OR REPLACE PROCEDURE vytvor_hrace(
    p_hrac_id NUMERIC,
    p_tym VARCHAR2,
    p_jmeno_hrace VARCHAR2,
    p_vek_hrace NUMERIC,
    p_pozice_hrace VARCHAR2,
    p_narodnost_hrace VARCHAR2
)
AS
BEGIN
    INSERT INTO Hrac (hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno)
    VALUES (p_hrac_id, p_jmeno_hrace, p_vek_hrace, p_pozice_hrace, p_narodnost_hrace, p_tym);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi pøidávání hráèe do týmu: ' || SQLERRM);
END;
/


-- Smazaní hráèe podle id
CREATE OR REPLACE PROCEDURE smaz_hrace(p_hrac_id NUMERIC) 
AS
BEGIN
    -- Smazání hráèe
    DELETE FROM Hrac WHERE hrac_id = p_hrac_id;

    -- Zkontrolujeme, zda byl nìjaký øádek smazán
    IF SQL%ROWCOUNT = 0 THEN
        -- Žádný øádek nebyl smazán, hráè s daným ID neexistuje
        RAISE_APPLICATION_ERROR(-20013, 'Hráè nelze smazat, protože neexistuje.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, 'Chyba pøi mazání hráèe: ' || SQLERRM);
END;
/

-- Procedura pro vytvoøení nového trenéra
CREATE OR REPLACE PROCEDURE vytvor_trenera(
    p_trener_jmeno VARCHAR2,
    p_trener_narodnost VARCHAR2,
    p_trener_vek NUMERIC,
    p_tym_jmeno VARCHAR2
)
AS
BEGIN
    INSERT INTO Trener (jmeno, narodnost, vek, tym_jmeno)
    VALUES (p_trener_jmeno, p_trener_narodnost, p_trener_vek, p_tym_jmeno);
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi pøidávání trenéra: ' || SQLERRM);
END;
/


-- Procedura pro smazání trenéra
CREATE OR REPLACE PROCEDURE smaz_trenera_podle_jmena_a_tymu(
    p_jmeno VARCHAR2,
    p_tym_jmeno VARCHAR2
) 
AS
BEGIN
    DELETE FROM Trener WHERE jmeno = p_jmeno AND tym_jmeno = p_tym_jmeno;
    IF SQL%ROWCOUNT = 0 THEN   
        RAISE_APPLICATION_ERROR(-20013, 'Trenér nelze smazat, protože neexistuje.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, 'Chyba pøi mazání trenéra: ' || SQLERRM);
END;
/


-- sekvence pro id zapasu, zaciname az od 8, protože prvních 7 zápasù vkládáme ruènì pomocí insertu, ne pomocí sekvence
CREATE SEQUENCE zapas_seq START WITH 8 INCREMENT BY 1;

-- Pøidání nového zápasu
CREATE OR REPLACE PROCEDURE vytvor_zapas(
    p_datum_zapasu TIMESTAMP,
    p_domaci_tym VARCHAR2,
    p_hoste_tym VARCHAR2,
    p_rozhodci_id NUMERIC,
    p_stadion_jmeno VARCHAR2
)
AS
    v_zapas_id NUMERIC;
BEGIN
    v_zapas_id := zapas_seq.NEXTVAL;
    
    -- Vložení nového zápasu
    INSERT INTO Zapas (zapas_id, datum, domaci, hoste, rozhodci_id, stadion_jmeno)
    VALUES (v_zapas_id,p_datum_zapasu, p_domaci_tym, p_hoste_tym, p_rozhodci_id, p_stadion_jmeno);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi vkládání nového zápasu: ' || SQLERRM);
END;
/

-- proceduru pro mazání jsem nevytváøela, jelikož zápas nelze smazat pokud existují týmy, které ho hrály, a pokud se smažou týmy, tak se zápas smaže kaskadou


-- Procedura pro vytvoøení nového rozhodèího
CREATE OR REPLACE PROCEDURE vytvor_rozhodciho(
    p_rozhodci_id NUMERIC,
    p_rozhodci_jmeno VARCHAR2,
    p_pocet_odpiskanych_zapasu NUMERIC,
    p_rozhodci_narodnost VARCHAR2
)
AS
BEGIN    
    -- Vložení nového rozhodèího
    INSERT INTO Rozhodci (rozhodci_id,jmeno, pocet_odpiskanych_zapasu, narodnost)
    VALUES (p_rozhodci_id,p_rozhodci_jmeno, p_pocet_odpiskanych_zapasu, p_rozhodci_narodnost);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi pøidávání rozhodèího: ' || SQLERRM);
END;
/

-- Procedura pro smazání rozhodèího
CREATE OR REPLACE PROCEDURE smaz_rozhodciho(p_rozhodci_id NUMERIC) 
AS
BEGIN
    -- Smazání rozhodèího
    DELETE FROM Rozhodci WHERE rozhodci_id = p_rozhodci_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Rozhodèí nelze smazat, protože neexistuje.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, 'Chyba pøi mazání rozhodèího: ' || SQLERRM);
END;
/


-- Procedura pro vkládání stadionu
CREATE OR REPLACE PROCEDURE vytvor_stadion(
    p_stadion_jmeno VARCHAR2,
    p_stadion_kapacita NUMERIC,
    p_adresa_ulice VARCHAR2,
    p_adresa_cislo_popisne NUMERIC,
    p_adresa_mesto VARCHAR2,
    p_adresa_psc NUMERIC,
    p_adresa_zeme VARCHAR2
)
AS
BEGIN
    -- Vložení stadionu
    INSERT INTO Stadion (jmeno, kapacita, ulice, cislo_popisne, mesto, psc, zeme)
    VALUES (p_stadion_jmeno, p_stadion_kapacita,p_adresa_ulice, p_adresa_cislo_popisne, p_adresa_mesto, p_adresa_psc, p_adresa_zeme);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi vkládání nového stadionu: ' || SQLERRM);
END;
/

-- smazání stadionu a jeho adresy
CREATE OR REPLACE PROCEDURE smaz_stadion(
    p_stadion_jmeno VARCHAR2
)
AS
BEGIN    
    DELETE FROM Stadion
    WHERE jmeno = p_stadion_jmeno;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Stadion nelze smazat, protože neexistuje.');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi mazání stadionu: ' || SQLERRM);
END;
/

-- Procedura pro vytvoøení týmu 
CREATE OR REPLACE PROCEDURE vytvor_novy_tym(
    p_tym_jmeno VARCHAR2,
    p_stadion_jmeno VARCHAR2,
    p_stadion_kapacita NUMERIC,
    p_adresa_ulice VARCHAR2,
    p_adresa_cislo_popisne NUMERIC,
    p_adresa_mesto VARCHAR2,
    p_adresa_psc NUMBER,
    p_adresa_zeme VARCHAR2
)
AS    
BEGIN    
    BEGIN
        vytvor_stadion(p_stadion_jmeno,p_stadion_kapacita, p_adresa_ulice, p_adresa_cislo_popisne, p_adresa_mesto, p_adresa_psc, p_adresa_zeme);
    EXCEPTION 
        WHEN OTHERS THEN 
            RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi vkládání stadionu: ' || SQLERRM);
            RAISE;
    END;
    -- Vložení nového týmu
    INSERT INTO Tym (jmeno, stadion_jmeno)
    VALUES (p_tym_jmeno, p_stadion_jmeno);
    
EXCEPTION
    -- Chyba v transakci, zrušení zmìn
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi vkládání nového týmu: ' || SQLERRM);
END;
/


-- Procedura pro smazání týmu, tým lze smazat pouze pokud nemá žádné hráèe a trenéry
CREATE OR REPLACE PROCEDURE smaz_tym_podle_jmena(p_tym_jmeno VARCHAR2) 
AS
    v_pocet_hracu NUMERIC;
    v_pocet_treneru NUMERIC;
BEGIN
    -- Získání poètu hráèù v týmu
    SELECT COUNT(*) INTO v_pocet_hracu
    FROM Hrac
    WHERE tym_jmeno = p_tym_jmeno;
    
    -- Získání poètu trenérù v týmu
    SELECT COUNT(*) INTO v_pocet_treneru
    FROM Trener
    WHERE tym_jmeno = p_tym_jmeno;

    -- Pokud tým nemá žádné hráèe ani trenéry, smažeme ho
    IF v_pocet_hracu = 0 AND v_pocet_treneru = 0 THEN
        BEGIN
            -- Smazání týmu
            DELETE FROM Tym WHERE jmeno = p_tym_jmeno;
            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-20013, 'Tym nelze smazat, protože neexistuje.');
            END IF;
        EXCEPTION
            -- Chyba v transakci, zrušení zmìn
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20010, 'Chyba pøi mazání týmu: ' || SQLERRM);
        END;
    ELSE
        -- Tým má hráèe nebo trenéry, nelze ho smazat
        RAISE_APPLICATION_ERROR(-20011, 'Tým nelze smazat, protože má hráèe nebo trenéry.');
    END IF;
EXCEPTION
    -- Chyba pøi získávání poètu hráèù nebo trenérù
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20012, 'Chyba pøi získávání poètu hráèù nebo trenérù: ' || SQLERRM);
END;
/


-- Pøidání hráèe do zápasu, mazat hráèe ze zápasu nedává smysl
CREATE OR REPLACE PROCEDURE hrac_hral_zapas(
    p_hrac_id NUMERIC,
    p_zapas_id NUMERIC
)
AS
BEGIN
    -- Vložení nového záznamu do tabulky HracHraje
    INSERT INTO HracHraje (hrac_id, zapas_id)
    VALUES (p_hrac_id, p_zapas_id);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi vkládání hráèe do zápasu: ' || SQLERRM);
END;
/

-- Hráè scóroval v zápase, opìt nebudeme vytváøe operaci pro smazání protože v tomto kontextu nedává smysl
CREATE OR REPLACE PROCEDURE hrac_scoroval_v_zapase(
    p_hrac_id NUMERIC,
    p_zapas_id NUMERIC,
    p_minuta NUMERIC
)
AS
BEGIN
       -- Vložení nového záznamu do tabulky HracScoruje
    INSERT INTO HracScoruje (hrac_id, zapas_id, minuta)
    VALUES (p_hrac_id, p_zapas_id, p_minuta);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi vkládání scórování hráèe v zápase: ' || SQLERRM);
END;
/

-- Procedura pro zmìnu rozhodèiho v zápase, smí se zmìnit jen pokud zápas ještì nebyl dohraný 
CREATE OR REPLACE PROCEDURE zmen_rozhodciho_zapasu(
    p_zapas_id NUMERIC,
    p_novy_rozhodci_id NUMERIC
)
AS
    v_dohrano NUMBER;
BEGIN
    -- Zjistíme zda byl zápas již dohrán
    SELECT dohrano INTO v_dohrano 
    FROM Zapas WHERE zapas_id = p_zapas_id;
    
    IF v_dohrano = 1 THEN
        RAISE_APPLICATION_ERROR(-20014, 'Zápas s ID ' || p_zapas_id || ' již byl dohrán, nelze zmìnit rozhodèího.');
    ELSE
        -- Aktualizace záznamu v tabulce Zapas s novým rozhodèím
        UPDATE Zapas SET rozhodci_id = p_novy_rozhodci_id WHERE zapas_id = p_zapas_id;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi zmìnì rozhodèího ve zápase: ' || SQLERRM);
END;
/

-- Procedura pro zmìnu datum zápasu, smí se zmìnit jen pokud zápas ještì nebyl dohraný 
CREATE OR REPLACE PROCEDURE zmen_datum_zapasu(
    p_zapas_id NUMERIC,
    p_nove_datum TIMESTAMP
)
AS
    v_aktualni_datum TIMESTAMP;
    v_dohrano NUMERIC;
BEGIN
    -- Získání aktuálního data a èasu
    SELECT SYSTIMESTAMP INTO v_aktualni_datum FROM DUAL;
    
    IF p_nove_datum < v_aktualni_datum THEN
        RAISE_APPLICATION_ERROR(-20002, 'Vkládané datum a èas nesmí být starší než aktuální datum a èas.');
    ELSE
        -- Získání informace, zda zápas byl dohrán
        SELECT v_dohrano INTO v_dohrano FROM Zapas WHERE zapas_id = p_zapas_id;
        
        IF v_dohrano = 1 THEN
            RAISE_APPLICATION_ERROR(-20014, 'Zápas s ID ' || p_zapas_id || ' již byl dohrán, nelze zmìnit datum.');
        ELSE
            -- Aktualizace záznamu v tabulce Zapas s novým datem
            UPDATE Zapas SET datum = p_nove_datum WHERE zapas_id = p_zapas_id;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi zmìnì data zápasu: ' || SQLERRM);
END;
/

-- Zmìnit stadion zápasu, pokud ještì zápas nebyl dohrán 
CREATE OR REPLACE PROCEDURE zmen_stadion_zapasu(
    p_zapas_id NUMERIC,
    p_novy_stadion_jmeno VARCHAR2
)
AS
BEGIN
    -- Aktualizace záznamu v tabulce Zapas s novým stadionem
    UPDATE Zapas SET stadion_jmeno = p_novy_stadion_jmeno WHERE zapas_id = p_zapas_id;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi zmìnì stadionu zápasu: ' || SQLERRM);
END;
/

-- Zmìníme hráèi tým, mùžeme ho buï pøidat do konkrétního týmu nebo mu nastavit tým na null
CREATE OR REPLACE PROCEDURE zmen_tym_hrace(
    p_hrac_id NUMERIC,
    p_novy_tym_jmeno VARCHAR2
)
AS
BEGIN
    -- Aktualizace záznamu v tabulce Hrac s novým týmem
    UPDATE Hrac SET tym_jmeno = p_novy_tym_jmeno WHERE hrac_id = p_hrac_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi zmìnì týmu hráèe: ' || SQLERRM);
END;
/

-- Zmìníme tým u trenéra nebo ho nastavíme na null
CREATE OR REPLACE PROCEDURE zmen_tym_trenera(
    p_jmeno VARCHAR2,
    p_stary_tym_jmeno VARCHAR2,
    p_novy_tym_jmeno VARCHAR2
)
AS
BEGIN

    -- Aktualizace záznamu v tabulce Trener s novým týmem
    UPDATE Trener SET tym_jmeno = p_novy_tym_jmeno 
    WHERE jmeno = p_jmeno AND tym_jmeno = p_stary_tym_jmeno;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi zmìnì týmu trenéra: ' || SQLERRM);
END;
/

-- Zapis výsledek zápasu
CREATE OR REPLACE PROCEDURE zapis_vysledek_zapasu(
    p_zapas_id NUMERIC,
    p_goly_domaci NUMERIC,
    p_goly_hoste NUMERIC
)
AS 
    v_domaci VARCHAR2(255);
    v_hoste VARCHAR2(255);
    v_vitez VARCHAR2(255);
    v_datum TIMESTAMP;
    v_aktualni_datum TIMESTAMP;
    v_dohrano NUMERIC := 1;
BEGIN
    SELECT SYSTIMESTAMP INTO v_aktualni_datum FROM DUAL;
    
    -- zda již mohl zápas probìhnout
    SELECT domaci, hoste, datum INTO v_domaci, v_hoste, v_datum
    FROM Zapas WHERE zapas_id = p_zapas_id;
    
    IF v_datum > v_aktualni_datum THEN
        RAISE_APPLICATION_ERROR(-20015, 'Zápas nemohl být dohrán, datum zápasu ještì nebylo.');
    END IF;

    -- Zjištìní kdo vyhrál 
    IF p_goly_domaci > p_goly_hoste THEN
        v_vitez := v_domaci;
    ELSIF p_goly_domaci < p_goly_hoste THEN
        v_vitez := v_hoste;
    ELSE
        v_vitez := NULL;
    END IF;
    
    -- update záznamu v tabulce
    UPDATE Zapas 
    SET dohrano = v_dohrano, goly_domaci = p_goly_domaci, goly_hoste = p_goly_hoste, vitez = v_vitez
    WHERE zapas_id = p_zapas_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi aktualizaci zápasu: ' || SQLERRM);
END;
/

-- Tato procedura zmìní týmu stadion
CREATE OR REPLACE PROCEDURE zmen_tym_stadion(
    p_tym_jmeno VARCHAR2,
    p_novy_stadion_jmeno VARCHAR2
)
AS
BEGIN
    -- Aktualizace záznamu v tabulce Tym s novým stadionem
    UPDATE Tym SET stadion_jmeno = p_novy_stadion_jmeno WHERE jmeno = p_tym_jmeno;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi zmìnì stadionu týmu: ' || SQLERRM);
END;
/

-- Procedury pro zmìnìní adresy stadionu nevytváøíme, jelikož pøedpokládáme, že stadion se neposouvá na jiné místo a pokud tým mìní stadion, tak se pravdìpodobnì vystavìl nový stadion na nové adrese
    
-- FUNKCE 
CREATE OR REPLACE FUNCTION pocet_hracu_v_tymu(
    p_tym_jmeno VARCHAR2
)
RETURN NUMBER
AS
    v_pocet_hracu NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_pocet_hracu
    FROM Hrac
    WHERE tym_jmeno = p_tym_jmeno;

    RETURN v_pocet_hracu;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; -- Return 0 if no players found for the team
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba pøi výpoètu poètu hráèù: ' || SQLERRM);
END;
/

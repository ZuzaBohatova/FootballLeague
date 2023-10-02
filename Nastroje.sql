
-- T�ma: Fotbalov� liga
-- Autor: Zuzana Bohatov�
-- v tomto scriptu najdete triggers, views, indexy a procedury.

-- Nejprve je nutn� spustit soubor Tabulky.sql

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

-- Zobrazen� tymu spolu s po�tem jeho tren�r� a jejich jmeny, a adresou stadionu 
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

-- View pro zobrazen� z�pasu spolu s jm�nem jeho rozhod�� a adresou stadionu 
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

-- View pro  hr��e - po�et z�pas�, g�l�, pr�m�rn� po�et gol� na z�pas
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


-- View na dvojice hr�� z�pas s dodate�n�mi informacemi o hr��i a z�pase
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
    
-- View pro zobrazen� informac� o hr��i, kter� sc�roval v z�pase a plus dodate�n� informace o z�pase
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

-- Tabulka tym� se�azen�ch podle po�ad� v lize
CREATE VIEW tabulka_tymu_vw AS 
    SELECT *
    FROM Tym
    ORDER BY pocet_bodu DESC, (goly_dal - goly_dostal) DESC;
    
-- Tabulka hr��� podle po�tu vst�elen�ch g�l�
CREATE VIEW nejlepsi_strelec_vw AS 
    SELECT *       
    FROM Hrac
    ORDER BY pocet_golu DESC;
        
-- TRIGGERS

-- Trigger, kter� aktualizuje statistiky ka�d�ho t�mu po dohran�m z�pase
CREATE OR REPLACE TRIGGER update_tymu_po_dohranem_zapasu
AFTER INSERT OR UPDATE OF dohrano ON Zapas
FOR EACH ROW
WHEN (new.dohrano = 1)
DECLARE
    v_domaci_tym VARCHAR2(255) := :new.domaci;
    v_hoste_tym VARCHAR2(255) := :new.hoste;
BEGIN
    IF :new.goly_domaci > :new.goly_hoste THEN
        -- V�t�zstv� dom�c�ho t�mu
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
        -- V�t�zstv� hostuj�c�ho t�mu
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
        -- Rem�za
        UPDATE Tym
        SET pocet_bodu = pocet_bodu + 1,
            pocet_remiz = pocet_remiz + 1,
            goly_dal = goly_dal + :new.goly_domaci,
            goly_dostal = goly_dostal + :new.goly_hoste
        WHERE jmeno IN (v_domaci_tym, v_hoste_tym);
    END IF;
END;
/

-- Trigger zv��� hr��i po�et g�l�, pokud v z�pase sc�roval 
CREATE OR REPLACE TRIGGER pridej_gol_scorujicimu_hraci
AFTER INSERT ON HracScoruje
FOR EACH ROW
BEGIN
    UPDATE Hrac
    SET pocet_golu = pocet_golu + 1
    WHERE hrac_id = :new.hrac_id;
END;
/

-- Trigger, kter� kontroluje, �e dom�c� a host� nejsou stejn� t�m
CREATE OR REPLACE TRIGGER hoste_domaci_nejsou_stejny_tym
BEFORE INSERT OR UPDATE OF domaci, hoste ON Zapas
FOR EACH ROW
BEGIN
    IF :NEW.domaci = :NEW.hoste THEN
        RAISE_APPLICATION_ERROR(-20001, 'Error: Dom�c� a host� nemohou b�t stejn� t�m.');
    END IF;
END;
/

-- Trigger, kter� kontroluje, �e v�t�z z�pasu odpov�d� bu� dom�c�m, host�m nebo null
CREATE OR REPLACE TRIGGER vitez_hral_zapas
BEFORE INSERT OR UPDATE OF vitez ON Zapas
FOR EACH ROW
BEGIN
    IF :NEW.vitez IS NOT NULL AND :NEW.vitez NOT IN (:NEW.domaci, :NEW.hoste) THEN
        RAISE_APPLICATION_ERROR(-20002, 'Error: Hodnota ve sloupci "vitez" mus� odpov�dat t�mu dom�c�ch, t�mu host� nebo b�t NULL.');
    END IF;
END;
/

-- Trigger hl�d�, �e t�m za kter� hraje hr�� dan� z�pas hr�l
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
        RAISE_APPLICATION_ERROR(-20003, 'Error: Hr�� nem��e hr�t z�pas, proto�e jeho t�m dan� z�pas nehr�l.');
    END IF;
END;
/

-- Trigger hl�d�, �e t�m za kter� hr�� sc�roval dan� z�pas hr�l
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
        RAISE_APPLICATION_ERROR(-20004, 'Error: Hr�� nem��e hr�t z�pas, proto�e jeho t�m dan� z�pas nehr�l.');
    END IF;
END;
/

-- Trigger, kter� hl�d�, �e pokud je u� z�pas dohran�, tak datum z�pasu je star�� ne� aktu�ln� datum, m� rozhod��ho a stadion
CREATE OR REPLACE TRIGGER zapas_muze_byt_dohrany
BEFORE INSERT OR UPDATE OF dohrano ON Zapas
FOR EACH ROW
DECLARE
    v_current_date TIMESTAMP;
BEGIN
    IF :NEW.dohrano = 1 THEN
        SELECT CURRENT_TIMESTAMP INTO v_current_date FROM DUAL;
        IF :NEW.datum >= v_current_date THEN
            RAISE_APPLICATION_ERROR(-20005, 'Error: Z�pas je�t� nem��e b�t dohran�, jeliko� �as a datum z�pasu je�t� nebylo.');
        END IF;

        IF :NEW.rozhodci_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20006, 'Error: Z�pas je dohr�n, ale nen� p�i�azen rozhod��.');
        END IF;

        IF :NEW.stadion_jmeno IS NULL THEN
            RAISE_APPLICATION_ERROR(-20007, 'Error: Z�pas je dohr�n, ale nen� p�i�azen stadion.');
        END IF;
    END IF;
END;
/

-- Trigger zakazuje smazat z�pas, pokud oba t�my st�le existuj� 
CREATE OR REPLACE TRIGGER zapas_zakaz_smazani
BEFORE DELETE ON Zapas
FOR EACH ROW
DECLARE
    v_dohrano NUMERIC(1,0) := :OLD.dohrano;
    v_domaci_tym_existuje NUMERIC(1,0);
    v_hoste_tym_existuje NUMERIC(1,0);
BEGIN

    IF v_dohrano = 1 THEN
        -- Zkontrolujeme, zda existuje dom�c� t�m
        SELECT COUNT(*) INTO v_domaci_tym_existuje
        FROM Tym
        WHERE jmeno = :OLD.domaci;

        -- Zkontrolujeme, zda existuje hostuj�c� t�m
        SELECT COUNT(*) INTO v_hoste_tym_existuje
        FROM Tym
        WHERE jmeno = :OLD.hoste;

        -- Pokud oba t�my existuj�, vyhod�me chybu, kter� zabr�n� smaz�n� z�pasu
        IF v_domaci_tym_existuje = 1 AND v_hoste_tym_existuje = 1 THEN
            RAISE_APPLICATION_ERROR(-20008, 'Error: Nelze smazat z�pas. Z�pas je dohran� a oba t�my st�le existuj�.');
        END IF;
    END IF;
END;
/

-- Trigger kotroluj�c� spr�vn� ur�en�ho v�t�ze podle padl�ch golu
CREATE OR REPLACE TRIGGER urci_viteze_zapasu
BEFORE INSERT OR UPDATE ON Zapas
FOR EACH ROW
BEGIN
    IF :NEW.goly_domaci > :NEW.goly_hoste THEN
        :NEW.vitez := :NEW.domaci;
    ELSIF :NEW.goly_domaci < :NEW.goly_hoste THEN
        :NEW.vitez := :NEW.hoste;
    ELSE
        :NEW.vitez := NULL; -- Rem�za
    END IF;
END;
/

-- Trigger, kter� p�i�te rozhod��mu odp�skan� z�pas
CREATE OR REPLACE TRIGGER pricti_rozhodcimu_odpiskany_zapas
AFTER INSERT OR UPDATE ON Zapas
FOR EACH ROW
DECLARE
    v_rozhodci_id NUMERIC(6, 0);
BEGIN
    -- Zkontrolujte, zda z�pas byl dohran� (dohrano = 1) a m� p�i�azen�ho rozhod��ho
    IF :NEW.dohrano = 1 AND :NEW.rozhodci_id IS NOT NULL THEN
        -- Z�skat ID rozhod��ho ze z�pasu
        v_rozhodci_id := :NEW.rozhodci_id;

        -- Zv��en� po�tu odp�skan�ch z�pas� pro dan�ho rozhod��ho
        UPDATE Rozhodci
        SET pocet_odpiskanych_zapasu = pocet_odpiskanych_zapasu + 1
        WHERE rozhodci_id = v_rozhodci_id;
    END IF;
END;
/


-- PROCEDURY

-- Procedura, kter� vlo�� nov�ho hr��e

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
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i p�id�v�n� hr��e do t�mu: ' || SQLERRM);
END;
/


-- Smazan� hr��e podle id
CREATE OR REPLACE PROCEDURE smaz_hrace(p_hrac_id NUMERIC) 
AS
BEGIN
    -- Smaz�n� hr��e
    DELETE FROM Hrac WHERE hrac_id = p_hrac_id;

    -- Zkontrolujeme, zda byl n�jak� ��dek smaz�n
    IF SQL%ROWCOUNT = 0 THEN
        -- ��dn� ��dek nebyl smaz�n, hr�� s dan�m ID neexistuje
        RAISE_APPLICATION_ERROR(-20013, 'Hr�� nelze smazat, proto�e neexistuje.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, 'Chyba p�i maz�n� hr��e: ' || SQLERRM);
END;
/

-- Procedura pro vytvo�en� nov�ho tren�ra
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
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i p�id�v�n� tren�ra: ' || SQLERRM);
END;
/


-- Procedura pro smaz�n� tren�ra
CREATE OR REPLACE PROCEDURE smaz_trenera_podle_jmena_a_tymu(
    p_jmeno VARCHAR2,
    p_tym_jmeno VARCHAR2
) 
AS
BEGIN
    DELETE FROM Trener WHERE jmeno = p_jmeno AND tym_jmeno = p_tym_jmeno;
    IF SQL%ROWCOUNT = 0 THEN   
        RAISE_APPLICATION_ERROR(-20013, 'Tren�r nelze smazat, proto�e neexistuje.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, 'Chyba p�i maz�n� tren�ra: ' || SQLERRM);
END;
/


-- sekvence pro id zapasu, zaciname az od 8, proto�e prvn�ch 7 z�pas� vkl�d�me ru�n� pomoc� insertu, ne pomoc� sekvence
CREATE SEQUENCE zapas_seq START WITH 8 INCREMENT BY 1;

-- P�id�n� nov�ho z�pasu
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
    
    -- Vlo�en� nov�ho z�pasu
    INSERT INTO Zapas (zapas_id, datum, domaci, hoste, rozhodci_id, stadion_jmeno)
    VALUES (v_zapas_id,p_datum_zapasu, p_domaci_tym, p_hoste_tym, p_rozhodci_id, p_stadion_jmeno);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i vkl�d�n� nov�ho z�pasu: ' || SQLERRM);
END;
/

-- proceduru pro maz�n� jsem nevytv��ela, jeliko� z�pas nelze smazat pokud existuj� t�my, kter� ho hr�ly, a pokud se sma�ou t�my, tak se z�pas sma�e kaskadou


-- Procedura pro vytvo�en� nov�ho rozhod��ho
CREATE OR REPLACE PROCEDURE vytvor_rozhodciho(
    p_rozhodci_id NUMERIC,
    p_rozhodci_jmeno VARCHAR2,
    p_pocet_odpiskanych_zapasu NUMERIC,
    p_rozhodci_narodnost VARCHAR2
)
AS
BEGIN    
    -- Vlo�en� nov�ho rozhod��ho
    INSERT INTO Rozhodci (rozhodci_id,jmeno, pocet_odpiskanych_zapasu, narodnost)
    VALUES (p_rozhodci_id,p_rozhodci_jmeno, p_pocet_odpiskanych_zapasu, p_rozhodci_narodnost);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i p�id�v�n� rozhod��ho: ' || SQLERRM);
END;
/

-- Procedura pro smaz�n� rozhod��ho
CREATE OR REPLACE PROCEDURE smaz_rozhodciho(p_rozhodci_id NUMERIC) 
AS
BEGIN
    -- Smaz�n� rozhod��ho
    DELETE FROM Rozhodci WHERE rozhodci_id = p_rozhodci_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Rozhod�� nelze smazat, proto�e neexistuje.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20010, 'Chyba p�i maz�n� rozhod��ho: ' || SQLERRM);
END;
/


-- Procedura pro vkl�d�n� stadionu
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
    -- Vlo�en� stadionu
    INSERT INTO Stadion (jmeno, kapacita, ulice, cislo_popisne, mesto, psc, zeme)
    VALUES (p_stadion_jmeno, p_stadion_kapacita,p_adresa_ulice, p_adresa_cislo_popisne, p_adresa_mesto, p_adresa_psc, p_adresa_zeme);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i vkl�d�n� nov�ho stadionu: ' || SQLERRM);
END;
/

-- smaz�n� stadionu a jeho adresy
CREATE OR REPLACE PROCEDURE smaz_stadion(
    p_stadion_jmeno VARCHAR2
)
AS
BEGIN    
    DELETE FROM Stadion
    WHERE jmeno = p_stadion_jmeno;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Stadion nelze smazat, proto�e neexistuje.');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i maz�n� stadionu: ' || SQLERRM);
END;
/

-- Procedura pro vytvo�en� t�mu 
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
            RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i vkl�d�n� stadionu: ' || SQLERRM);
            RAISE;
    END;
    -- Vlo�en� nov�ho t�mu
    INSERT INTO Tym (jmeno, stadion_jmeno)
    VALUES (p_tym_jmeno, p_stadion_jmeno);
    
EXCEPTION
    -- Chyba v transakci, zru�en� zm�n
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i vkl�d�n� nov�ho t�mu: ' || SQLERRM);
END;
/


-- Procedura pro smaz�n� t�mu, t�m lze smazat pouze pokud nem� ��dn� hr��e a tren�ry
CREATE OR REPLACE PROCEDURE smaz_tym_podle_jmena(p_tym_jmeno VARCHAR2) 
AS
    v_pocet_hracu NUMERIC;
    v_pocet_treneru NUMERIC;
BEGIN
    -- Z�sk�n� po�tu hr��� v t�mu
    SELECT COUNT(*) INTO v_pocet_hracu
    FROM Hrac
    WHERE tym_jmeno = p_tym_jmeno;
    
    -- Z�sk�n� po�tu tren�r� v t�mu
    SELECT COUNT(*) INTO v_pocet_treneru
    FROM Trener
    WHERE tym_jmeno = p_tym_jmeno;

    -- Pokud t�m nem� ��dn� hr��e ani tren�ry, sma�eme ho
    IF v_pocet_hracu = 0 AND v_pocet_treneru = 0 THEN
        BEGIN
            -- Smaz�n� t�mu
            DELETE FROM Tym WHERE jmeno = p_tym_jmeno;
            IF SQL%ROWCOUNT = 0 THEN
                RAISE_APPLICATION_ERROR(-20013, 'Tym nelze smazat, proto�e neexistuje.');
            END IF;
        EXCEPTION
            -- Chyba v transakci, zru�en� zm�n
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20010, 'Chyba p�i maz�n� t�mu: ' || SQLERRM);
        END;
    ELSE
        -- T�m m� hr��e nebo tren�ry, nelze ho smazat
        RAISE_APPLICATION_ERROR(-20011, 'T�m nelze smazat, proto�e m� hr��e nebo tren�ry.');
    END IF;
EXCEPTION
    -- Chyba p�i z�sk�v�n� po�tu hr��� nebo tren�r�
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20012, 'Chyba p�i z�sk�v�n� po�tu hr��� nebo tren�r�: ' || SQLERRM);
END;
/


-- P�id�n� hr��e do z�pasu, mazat hr��e ze z�pasu ned�v� smysl
CREATE OR REPLACE PROCEDURE hrac_hral_zapas(
    p_hrac_id NUMERIC,
    p_zapas_id NUMERIC
)
AS
BEGIN
    -- Vlo�en� nov�ho z�znamu do tabulky HracHraje
    INSERT INTO HracHraje (hrac_id, zapas_id)
    VALUES (p_hrac_id, p_zapas_id);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i vkl�d�n� hr��e do z�pasu: ' || SQLERRM);
END;
/

-- Hr�� sc�roval v z�pase, op�t nebudeme vytv��e operaci pro smaz�n� proto�e v tomto kontextu ned�v� smysl
CREATE OR REPLACE PROCEDURE hrac_scoroval_v_zapase(
    p_hrac_id NUMERIC,
    p_zapas_id NUMERIC,
    p_minuta NUMERIC
)
AS
BEGIN
       -- Vlo�en� nov�ho z�znamu do tabulky HracScoruje
    INSERT INTO HracScoruje (hrac_id, zapas_id, minuta)
    VALUES (p_hrac_id, p_zapas_id, p_minuta);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i vkl�d�n� sc�rov�n� hr��e v z�pase: ' || SQLERRM);
END;
/

-- Procedura pro zm�nu rozhod�iho v z�pase, sm� se zm�nit jen pokud z�pas je�t� nebyl dohran� 
CREATE OR REPLACE PROCEDURE zmen_rozhodciho_zapasu(
    p_zapas_id NUMERIC,
    p_novy_rozhodci_id NUMERIC
)
AS
    v_dohrano NUMBER;
BEGIN
    -- Zjist�me zda byl z�pas ji� dohr�n
    SELECT dohrano INTO v_dohrano 
    FROM Zapas WHERE zapas_id = p_zapas_id;
    
    IF v_dohrano = 1 THEN
        RAISE_APPLICATION_ERROR(-20014, 'Z�pas s ID ' || p_zapas_id || ' ji� byl dohr�n, nelze zm�nit rozhod��ho.');
    ELSE
        -- Aktualizace z�znamu v tabulce Zapas s nov�m rozhod��m
        UPDATE Zapas SET rozhodci_id = p_novy_rozhodci_id WHERE zapas_id = p_zapas_id;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i zm�n� rozhod��ho ve z�pase: ' || SQLERRM);
END;
/

-- Procedura pro zm�nu datum z�pasu, sm� se zm�nit jen pokud z�pas je�t� nebyl dohran� 
CREATE OR REPLACE PROCEDURE zmen_datum_zapasu(
    p_zapas_id NUMERIC,
    p_nove_datum TIMESTAMP
)
AS
    v_aktualni_datum TIMESTAMP;
    v_dohrano NUMERIC;
BEGIN
    -- Z�sk�n� aktu�ln�ho data a �asu
    SELECT SYSTIMESTAMP INTO v_aktualni_datum FROM DUAL;
    
    IF p_nove_datum < v_aktualni_datum THEN
        RAISE_APPLICATION_ERROR(-20002, 'Vkl�dan� datum a �as nesm� b�t star�� ne� aktu�ln� datum a �as.');
    ELSE
        -- Z�sk�n� informace, zda z�pas byl dohr�n
        SELECT v_dohrano INTO v_dohrano FROM Zapas WHERE zapas_id = p_zapas_id;
        
        IF v_dohrano = 1 THEN
            RAISE_APPLICATION_ERROR(-20014, 'Z�pas s ID ' || p_zapas_id || ' ji� byl dohr�n, nelze zm�nit datum.');
        ELSE
            -- Aktualizace z�znamu v tabulce Zapas s nov�m datem
            UPDATE Zapas SET datum = p_nove_datum WHERE zapas_id = p_zapas_id;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i zm�n� data z�pasu: ' || SQLERRM);
END;
/

-- Zm�nit stadion z�pasu, pokud je�t� z�pas nebyl dohr�n 
CREATE OR REPLACE PROCEDURE zmen_stadion_zapasu(
    p_zapas_id NUMERIC,
    p_novy_stadion_jmeno VARCHAR2
)
AS
BEGIN
    -- Aktualizace z�znamu v tabulce Zapas s nov�m stadionem
    UPDATE Zapas SET stadion_jmeno = p_novy_stadion_jmeno WHERE zapas_id = p_zapas_id;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i zm�n� stadionu z�pasu: ' || SQLERRM);
END;
/

-- Zm�n�me hr��i t�m, m��eme ho bu� p�idat do konkr�tn�ho t�mu nebo mu nastavit t�m na null
CREATE OR REPLACE PROCEDURE zmen_tym_hrace(
    p_hrac_id NUMERIC,
    p_novy_tym_jmeno VARCHAR2
)
AS
BEGIN
    -- Aktualizace z�znamu v tabulce Hrac s nov�m t�mem
    UPDATE Hrac SET tym_jmeno = p_novy_tym_jmeno WHERE hrac_id = p_hrac_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i zm�n� t�mu hr��e: ' || SQLERRM);
END;
/

-- Zm�n�me t�m u tren�ra nebo ho nastav�me na null
CREATE OR REPLACE PROCEDURE zmen_tym_trenera(
    p_jmeno VARCHAR2,
    p_stary_tym_jmeno VARCHAR2,
    p_novy_tym_jmeno VARCHAR2
)
AS
BEGIN

    -- Aktualizace z�znamu v tabulce Trener s nov�m t�mem
    UPDATE Trener SET tym_jmeno = p_novy_tym_jmeno 
    WHERE jmeno = p_jmeno AND tym_jmeno = p_stary_tym_jmeno;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i zm�n� t�mu tren�ra: ' || SQLERRM);
END;
/

-- Zapis v�sledek z�pasu
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
    
    -- zda ji� mohl z�pas prob�hnout
    SELECT domaci, hoste, datum INTO v_domaci, v_hoste, v_datum
    FROM Zapas WHERE zapas_id = p_zapas_id;
    
    IF v_datum > v_aktualni_datum THEN
        RAISE_APPLICATION_ERROR(-20015, 'Z�pas nemohl b�t dohr�n, datum z�pasu je�t� nebylo.');
    END IF;

    -- Zji�t�n� kdo vyhr�l 
    IF p_goly_domaci > p_goly_hoste THEN
        v_vitez := v_domaci;
    ELSIF p_goly_domaci < p_goly_hoste THEN
        v_vitez := v_hoste;
    ELSE
        v_vitez := NULL;
    END IF;
    
    -- update z�znamu v tabulce
    UPDATE Zapas 
    SET dohrano = v_dohrano, goly_domaci = p_goly_domaci, goly_hoste = p_goly_hoste, vitez = v_vitez
    WHERE zapas_id = p_zapas_id;
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i aktualizaci z�pasu: ' || SQLERRM);
END;
/

-- Tato procedura zm�n� t�mu stadion
CREATE OR REPLACE PROCEDURE zmen_tym_stadion(
    p_tym_jmeno VARCHAR2,
    p_novy_stadion_jmeno VARCHAR2
)
AS
BEGIN
    -- Aktualizace z�znamu v tabulce Tym s nov�m stadionem
    UPDATE Tym SET stadion_jmeno = p_novy_stadion_jmeno WHERE jmeno = p_tym_jmeno;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i zm�n� stadionu t�mu: ' || SQLERRM);
END;
/

-- Procedury pro zm�n�n� adresy stadionu nevytv���me, jeliko� p�edpokl�d�me, �e stadion se neposouv� na jin� m�sto a pokud t�m m�n� stadion, tak se pravd�podobn� vystav�l nov� stadion na nov� adrese
    
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
        RAISE_APPLICATION_ERROR(-20009, 'Chyba p�i v�po�tu po�tu hr���: ' || SQLERRM);
END;
/

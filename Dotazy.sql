
-- Tema: Fotbalova liga
-- Autor: Zuzana Bohatova
-- Dotazy nad daty a smazani celeho schematu 


-- Views
SELECT * FROM tym_vw;
SELECT * FROM zapasy_info_vw;
SELECT * FROM hrac_statistika_vw;
SELECT * FROM hracHraje_vw;
SELECT * FROM hracScoruje_vw;
SELECT * FROM tabulka_tymu_vw;
SELECT * FROM nejlepsi_strelec_vw;

-- Test Triggers a Procedures

-- Test vlozeni noveho tymu - procedury vytvor_novy_tym, procedury vytvor_stadion 
-- Rovnou si tim overime i zda funguje procedure vytvor_stadion, jelikoe tuto proceduru pouzivame uvnitr procedury vytvor_novy_tym
SELECT * FROM tym_vw;
EXEC u86974125.vytvor_novy_tym('MFK Karvina', 'Mestsky stadion Karvina', 4833, 'U hriste', 1700, 'Karvina', 73401, 'Ceska republika');
SELECT * FROM tym_vw;

-- pokud se pokusime znovu vytvorit stejny tym, vyhodi nam to chybu, jelikoz jmeno neni unikatni 
EXEC u86974125.vytvor_novy_tym('MFK Karvina', 'Mestsky stadion Karvina', 4833, 'U hriste', 1700, 'Karvina', 73401, 'Ceska republika');
-- stejne tak pokud se pokusime znovu vytvorit stejne stadion
EXEC u86974125.vytvor_stadion('Mestsky stadion Karvina', 4833, 'U hriste', 1700, 'Karvina', 73401, 'Ceska republika');

--  Test procedury vytvor_trenera
-- Nejprve se pokusime vlozit trenera k neexistujicimu tymu = chyba
EXEC u86974125.vytvor_trenera('Lubomir Luhovy', 'SVK', 66, 'FC Banik Ostrava');
SELECT * FROM Trener;

-- Pote vlozime trenera s jiz validnimi udaji
EXEC u86974125.vytvor_trenera('Lubomir Luhovy', 'SVK', 66, 'MFK Karvina');
-- vidime, zda se nam trener uspesne pridal k danemu tymu
SELECT * FROM tym_vw; 

-- Test procedury vytvor_hrace
-- nejprve zkusime pridat hrace k neexistujicimu tymu, dostaneme chybu
EXEC u86974125.vytvor_hrace(00000061,'FC Banik Ostrava', 'Jaroslav Svozil', 29,'obrance','CZE');
SELECT * FROM hrac_statistika_vw;
-- pote vlozime hrace s validnim tymem
EXEC u86974125.vytvor_hrace(00000061,'MFK Karvina', 'Jaroslav Svozil', 29,'obrance','CZE');
-- a vidime, ze se nam hrac uspesne vlozil
SELECT * FROM hrac_statistika_vw WHERE tym_jmeno = 'MFK Karvina';

-- Test procedury vytvor_rozhodciho
EXEC u86974125.vytvor_rozhodciho(0000006,'Jan Novak', 0, 'CZE');
SELECT * from Rozhodci;

-- Test procedury vytvor_zapas
-- Chyba - domaci tym neexistuje
SELECT * FROM zapasy_info_vw;
EXEC u86974125.vytvor_zapas(TO_TIMESTAMP('08-09-2023 12:00', 'DD-MM-RRRR HH24:MI'),'FC Banik Ostrava','FC Slovan Liberec', 000001, 'Stadion U Nisy');
-- Chyba - tym hostu neexistuje
EXEC u86974125.vytvor_zapas(TO_TIMESTAMP('08-09-2023 12:00', 'DD-MM-RRRR HH24:MI'),'FC Slovan Liberec','FC Banik Ostrava', 000001, 'Stadion U Nisy');
-- Chyba - rozhodci neexistuje
EXEC u86974125.vytvor_zapas(TO_TIMESTAMP('08-09-2023 12:00', 'DD-MM-RRRR HH24:MI'),'FC Slovan Liberec','MFK Karvina', 123456, 'Stadion U Nisy');
-- Chyba - stadion neexistuje 
EXEC u86974125.vytvor_zapas(TO_TIMESTAMP('11-09-2023 12:00', 'DD-MM-RRRR HH24:MI'),'FC Slovan Liberec','MFK Karvina', 000001, 'Neexistujici Stadion');
-- Test triggeru hoste_domaci_nejsou_stejny_tym
EXEC u86974125.vytvor_zapas(TO_TIMESTAMP('08-09-2023 12:00', 'DD-MM-RRRR HH24:MI'),'FC Slovan Liberec','FC Slovan Liberec', 000001, 'Stadion U Nisy');
-- Spravne vlozeni zapas
EXEC u86974125.vytvor_zapas(TO_TIMESTAMP('08-09-2023 12:00', 'DD-MM-RRRR HH24:MI'),'FC Slovan Liberec','MFK Karvina', 000001, 'Stadion U Nisy');
SELECT * FROM zapasy_info_vw;

-- Test procedury zmen_tym_stadion
-- nejprve to vyzkousime se stadionem co neexistuje - dostaneme chybu
EXEC u86974125.zmen_tym_stadion('MFK Karvina','Novy stadion Karvina');
-- vytvorime si tedy novy stadion
EXEC u86974125.vytvor_stadion('Novy stadion Karvina', 6574, 'U noveho stadionu', 1721, 'Karvina', 73401, 'Ceska republika');
-- a nyni zmenime stadion u tymu 
EXEC u86974125.zmen_tym_stadion('MFK Karvina','Novy stadion Karvina');
SELECT * FROM tym_vw;

-- Test procedury zmen_tym_hrace
-- Nejprve otestujeme zda vyhodi chybu pro neexistujici tym
SELECT * FROM Hrac WHERE hrac_id = 00000042;
EXEC u86974125.zmen_tym_hrace(00000042,'FC Banik Ostrava');
-- nyni zadame validni udaje 
EXEC u86974125.zmen_tym_hrace(00000042,'MFK Karvina');
-- Overime si zmenu 
SELECT * FROM Hrac WHERE hrac_id = 00000042;

-- Test procedury zmen_stadion_zapasu
SELECT * FROM zapasy_info_vw WHERE zapas_id = 000001;
EXEC u86974125.zmen_stadion_zapasu(000001, 'Stadion U Nisy');
-- Test procedury zmen_rozhodciho 
EXEC u86974125.zmen_rozhodciho_zapasu(000001, 000002);
-- Test procedury zmen_datum_zapasu
EXEC u86974125.zmen_datum_zapasu(000001, TO_TIMESTAMP('28-09-2023 17:00','DD-MM-RRRR HH24:MI'));
SELECT * FROM zapasy_info_vw WHERE zapas_id = 000001;

-- Test procedury zapis_vysledek_zapasu
-- Test triggeru update_tymu_po_dohranem_zapasu, urci_viteze_zapasu, zapas_muze_byt_dohrany, vitez_hral_zapas
-- zaroven take triggeru zapas_muze_byt_dohrany
-- Nastane chyba, jelikoz datum zapasu jeste nebylo, tak nemuzeme zapsat vysledek zapasu
SELECT * FROM zapasy_info_vw;
EXEC u86974125.zapis_vysledek_zapasu(000007, 3,0);
-- Validni zapsani vysledku zapasu
EXEC u86974125.zapis_vysledek_zapasu(000006, 3,0);
-- Zkontrolujeme si zda je spravne urceny vitez zapasu podle vysledku
SELECT * FROM zapasy_info_vw WHERE zapas_id = 000006;
-- Zkontrolujeme zda viteznemu tymu v tabulce pribyly tri body, zvysil se pocet vyher atd.
SELECT * FROM tym_vw;
-- Zkontrolujeme zda se rozhodcimu pripocetl opiskany zapas - trigger pricti_rozhodcimu_odpiskany_zapas
SELECT * FROM Rozhodci; 

-- Test procedury hrac_scoroval_v_zapase, triggeru tym_scorujiciho_hrace_hral_zapas, 
EXEC u86974125.hrac_scoroval_v_zapase(00000002, 000006,10);
EXEC u86974125.hrac_scoroval_v_zapase(00000003, 000006,22);
EXEC u86974125.hrac_scoroval_v_zapase(00000002, 000006,70);
-- kazdy dany gol s informacemi o hraci a zapase ve kterem padnul
SELECT * FROM hracscoruje_vw WHERE zapas_id = 000006;


-- Test triggeru pridej_gol_scorujicimu_hraci - zkontrolujeme zda hraci pribyly goly
SELECT * FROM nejlepsi_strelec_vw;

-- Test triggeru zapas_zakaz_smazani
DELETE FROM Zapas WHERE zapas_id = 000006;

-- Test procedury hrac_hral_zapas, triggeru hracuv_tym_hral_zapas
EXEC u86974125.hrac_hral_zapas(00000002, 000006);
EXEC u86974125.hrac_hral_zapas(00000003, 000006);
SELECT * FROM hrachraje_vw WHERE zapas_id = 0000006;

-- Test procedury smaz_tym 
-- tym nepujde smazat a dostaneme chybu, jelikoz tym stale ma hrace nebo trenery
EXEC u86974125.smaz_tym_podle_jmena('MFK Karvina');
SELECT * FROM tym_vw;

--Test procedury smaz_trenera_podle_jmena_a_tymu
-- chyba - zadany trener neexistuje
SELECT * FROM Trener;
EXEC u86974125.smaz_trenera_podle_jmena_a_tymu('Pan Neexistuje','MFK Karvina');
-- validni smazani trenera
EXEC u86974125.smaz_trenera_podle_jmena_a_tymu('Lubomir Luhovy','MFK Karvina');
SELECT * FROM Trener;

-- Test procedury smaz_hrace
-- Neprojde, dane id neexistuje
SELECT * FROM hrac_statistika_vw WHERE hrac_id = 00000061;
EXEC u86974125.smaz_hrace(12345678);
-- validni smazani hrace
EXEC u86974125.smaz_hrace(00000061);
EXEC u86974125.smaz_hrace(00000042);
SELECT * FROM hrac_statistika_vw WHERE hrac_id = 00000061;

-- nyni muzeme validne smazat tym 
EXEC u86974125.smaz_tym_podle_jmena('MFK Karvina');
SELECT * FROM tym_vw;
-- nahledneme, ze se smazaly i zapasy tymu
SELECT * FROM zapasy_info_vw;

-- Test procedury smaz_stadion
-- Nejprve otestujeme reakci na neexistujici stadion
EXEC u86974125.smaz_stadion('Neexistujici stadion');
-- A nyni stadion validne smazeme 
EXEC u86974125.smaz_stadion('Mestsky stadion Karvina');
EXEC u86974125.smaz_stadion('Novy stadion Karvina');
SELECT * FROM Stadion;

-- Test procedury smaz_rozhodciho
EXEC u86974125.smaz_rozhodciho(000005);
SELECT * FROM Rozhodci;

-- Drop schematu

DROP VIEW tym_vw;
DROP VIEW zapasy_info_vw;
DROP VIEW hrac_statistika_vw;
DROP VIEW hracHraje_vw;
DROP VIEW hracScoruje_vw;
DROP VIEW tabulka_tymu_vw;
DROP VIEW nejlepsi_strelec_vw;

DROP SEQUENCE zapas_seq;

DROP TRIGGER update_tymu_po_dohranem_zapasu;
DROP TRIGGER pridej_gol_scorujicimu_hraci;
DROP TRIGGER hoste_domaci_nejsou_stejny_tym;
DROP TRIGGER vitez_hral_zapas;
DROP TRIGGER hracuv_tym_hral_zapas;
DROP TRIGGER tym_scorujiciho_hrace_hral_zapas;
DROP TRIGGER zapas_muze_byt_dohrany;
DROP TRIGGER zapas_zakaz_smazani;
DROP TRIGGER urci_viteze_zapasu;
DROP TRIGGER pricti_rozhodcimu_odpiskany_zapas;

DROP PROCEDURE vytvor_novy_tym;
DROP PROCEDURE smaz_tym_podle_jmena;
DROP PROCEDURE vytvor_hrace;
DROP PROCEDURE smaz_hrace;
DROP PROCEDURE vytvor_trenera;
DROP PROCEDURE smaz_trenera_podle_jmena_a_tymu;
DROP PROCEDURE vytvor_zapas;
DROP PROCEDURE vytvor_rozhodciho;
DROP PROCEDURE smaz_rozhodciho;
DROP PROCEDURE vytvor_stadion;
DROP PROCEDURE smaz_stadion;
DROP PROCEDURE hrac_hral_zapas;
DROP PROCEDURE hrac_scoroval_v_zapase;
DROP PROCEDURE zmen_rozhodciho_zapasu;
DROP PROCEDURE zmen_datum_zapasu;
DROP PROCEDURE zmen_stadion_zapasu;
DROP PROCEDURE zmen_tym_hrace;
DROP PROCEDURE zapis_vysledek_zapasu;
DROP PROCEDURE zmen_tym_stadion;
DROP PROCEDURE zmen_tym_trenera;

DROP FUNCTION pocet_hracu_v_tymu;

DROP TABLE HracScoruje;
DROP TABLE HracHraje;
DROP TABLE Hrac;
DROP TABLE Trener;
DROP TABLE Zapas;
DROP TABLE Rozhodci;
DROP TABLE Tym;
DROP TABLE Stadion;
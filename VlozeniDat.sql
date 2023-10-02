
-- Tema: Fotbalova liga
-- Autor: Zuzana Bohatova
-- Vlozeni dat - nejprve spustte scripty Tabulky.sql a Nastroje.sql

INSERT INTO Stadion(jmeno, kapacita, ulice,cislo_popisne,mesto,psc,zeme) VALUES('epet ARENA', 18349, 'Milady Horakove', 1066, 'Praha', 17000, 'Ceska republika');
INSERT INTO Stadion(jmeno, kapacita, ulice,cislo_popisne,mesto,psc,zeme) VALUES('Fortuna Arena', 19370, 'U Slavie', 1540, 'Praha', 10000, 'Ceska republika');
INSERT INTO Stadion(jmeno, kapacita, ulice,cislo_popisne,mesto,psc,zeme) VALUES('AGC Arena Na Stinadlech', 18221, 'Na Stinadlech', 2796, 'Teplice', 41501, 'Ceska republika');
INSERT INTO Stadion(jmeno, kapacita, ulice,cislo_popisne,mesto,psc,zeme) VALUES('Mestsky fotbalovy stadion Miroslava Valenty', 8000, 'Stonky', 566, 'Uherske Hradiste', 68601, 'Ceska republika');
INSERT INTO Stadion(jmeno, kapacita, ulice,cislo_popisne,mesto,psc,zeme) VALUES('LOKOTRANS ARENA Mlada Boleslav', 5000, 'U Stadionu', 1118, 'Mlada Boleslav', 29301 , 'Ceska republika');
INSERT INTO Stadion(jmeno, kapacita, ulice,cislo_popisne,mesto,psc,zeme) VALUES('Stadion U Nisy', 9900, 'Na Hradbach', 1300, 'Liberec', 46001 , 'Ceska republika');

COMMIT;

INSERT INTO Tym(jmeno, stadion_jmeno) VALUES('AC Sparta Praha', 'epet ARENA');
INSERT INTO Tym(jmeno, stadion_jmeno) VALUES('SK Slavia Praha', 'Fortuna Arena');
INSERT INTO Tym(jmeno, stadion_jmeno) VALUES('FK Teplice', 'AGC Arena Na Stinadlech');
INSERT INTO Tym(jmeno, stadion_jmeno) VALUES('1.FC Slovacko', 'Mestsky fotbalovy stadion Miroslava Valenty');
INSERT INTO Tym(jmeno, stadion_jmeno) VALUES('FK Mlada Boleslav', 'LOKOTRANS ARENA Mlada Boleslav');
INSERT INTO Tym(jmeno, stadion_jmeno) VALUES('FC Slovan Liberec', 'Stadion U Nisy');

COMMIT;

INSERT INTO Trener(jmeno, narodnost, vek, tym_jmeno) VALUES ('Brian Priske','DNK',46,'AC Sparta Praha');
INSERT INTO Trener(jmeno, narodnost, vek, tym_jmeno) VALUES ('Jindrich Trpisovsky','CZE',47,'SK Slavia Praha');
INSERT INTO Trener(jmeno, narodnost, vek, tym_jmeno) VALUES ('Zdenko Frtala','SVK',53,'FK Teplice');
INSERT INTO Trener(jmeno, narodnost, vek, tym_jmeno) VALUES ('Martin Svedik','CZE',49,'1.FC Slovacko');
INSERT INTO Trener(jmeno, narodnost, vek, tym_jmeno) VALUES ('Marek Kulic','CZE',47,'FK Mlada Boleslav');
INSERT INTO Trener(jmeno, narodnost, vek, tym_jmeno) VALUES ('Lubos Kozel','CZE',52,'FC Slovan Liberec');

COMMIT;

INSERT INTO Rozhodci(rozhodci_id, jmeno, narodnost) VALUES (000001,'Dalibor Cerny','CZE');
INSERT INTO Rozhodci(rozhodci_id, jmeno, narodnost) VALUES (000002,'Tomas Bartik','CZE');
INSERT INTO Rozhodci(rozhodci_id, jmeno, narodnost) VALUES (000003,'Pavel Orel','CZE');
INSERT INTO Rozhodci(rozhodci_id, jmeno, narodnost) VALUES (000004,'Dominik Stary','CZE');
INSERT INTO Rozhodci(rozhodci_id, jmeno, narodnost) VALUES (000005,'Jan Petrik','CZE');

COMMIT;

INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000001,'Ondrej Kolar',28,'brankar','CZE','SK Slavia Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000002,'Lukas Provod',26,'zaloznik','CZE','SK Slavia Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000003,'Mick Van Buren',30,'utocnik','NLD','SK Slavia Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000004,'Igoh Ogbu',23,'obrance','NGA','SK Slavia Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000005,'Murphy Dorley Oscar',25,'obrance','LBR','SK Slavia Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000006,'Lukas Masopust',30,'zaloznik','CZE','SK Slavia Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000007,'Vaclav Jurecka',29,'utocnik','CZE','SK Slavia Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000008,'Mojmir Chytil',24,'utocnik','CZE','SK Slavia Praha');

COMMIT;

INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000011,'Vojtech Vorel',27,'brankar','CZE','AC Sparta Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000012,'Lukas Haraslin',27,'zaloznik','SVK','AC Sparta Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000013,'Jan Kuchta',26,'utocnik','CZE','AC Sparta Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000014,'Jan Mejdr',24,'obrance','CZE','AC Sparta Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000015,'Filip Panak',27,'obrance','CZE','AC Sparta Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000016,'Ladislav Krejci',24,'zaloznik','CZE','AC Sparta Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000017,'Vaclav Sejk',21,'utocnik','CZE','AC Sparta Praha');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000018,'Veljko Birmancevic',25,'utocnik','CZE','AC Sparta Praha');

COMMIT;

INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000021,'Tomas Grigar',40,'brankar','CZE','FK Teplice');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000022,'Stepan Chaloupek',20,'obrance','CZE','FK Teplice');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000023,'Soufiane Drame',27,'obrance','FRA','FK Teplice');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000024,'Robert Jukl',24,'zaloznik','SVK','FK Teplice');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000025,'Daniel Trubac',26,'zaloznik','CZE','FK Teplice');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000026,'Jakub Urbanec',31,'zaloznik','CZE','FK Teplice');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000027,'Daniel Fila',20,'utocnik','CZE','FK Teplice');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000028,'Abdallah Gning',24,'utocnik','SEN','FK Teplice');

COMMIT;

INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000031,'Milan Heca',32,'brankar','CZE','1.FC Slovacko');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000032,'Michal Kadlec',38,'obrance','CZE','1.FC Slovacko');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000033,'Petr Reinberk',34,'obrance','CZE','1.FC Slovacko');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000034,'Daniel Holzer',27,'zaloznik','CZE','1.FC Slovacko');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000035,'Seung-Bin Kim',22,'zaloznik','KOR','1.FC Slovacko');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000036,'Vlasij Sinjavskij',26,'zaloznik','EST','1.FC Slovacko');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000037,'Rigino Cicilia',28,'utocnik','NLD','1.FC Slovacko');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000038,'Filip Vecheta',20,'utocnik','CZE','1.FC Slovacko');

COMMIT;

INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000041,'Matous Trmal', 24,'brankar','CZE','FK Mlada Boleslav');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000042,'Dominik Kostka',27,'obrance','CZE','FK Mlada Boleslav');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000043,'Benson Sakala',26,'obrance','ZMB','FK Mlada Boleslav');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000044,'Ladislav Kodad',25,'zaloznik','CZE','FK Mlada Boleslav');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000045,'Jakub Fulnek',29,'zaloznik','CZE','FK Mlada Boleslav');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000046,'Marek Matejovsky',41,'zaloznik','CZE','FK Mlada Boleslav');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000047,'Lamin Jawo',28,'utocnik','GMB','FK Mlada Boleslav');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000048,'Matej Pulkrab',26,'utocnik','CZE','FK Mlada Boleslav');

COMMIT;

INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000051,'Olivier Vliegen', 24,'brankar','BEL','FC Slovan Liberec');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000052,'	Michal Fukala',22,'obrance','CZE','FC Slovan Liberec');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000053,'Jan Mikula',31,'obrance','CZE','FC Slovan Liberec');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000054,'Mohamed Doumbia',24,'zaloznik','CIV','FC Slovan Liberec');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000055,'Ahmad Ghali',23,'zaloznik','NGA','FC Slovan Liberec');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000056,'Ivan Varfolomejev',19,'zaloznik','UKR','FC Slovan Liberec');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000057,'Filip Horsky',20,'utocnik','CZE','FC Slovan Liberec');
INSERT INTO Hrac(hrac_id, jmeno, vek, pozice, narodnost, tym_jmeno) 
VALUES (00000058,'Lubomir Tupta',25,'utocnik','SVK','FC Slovan Liberec');

COMMIT;

INSERT INTO Zapas(zapas_id,datum, domaci, hoste, rozhodci_id, stadion_jmeno)
VALUES (000001, TO_TIMESTAMP('02-09-2023 12:00', 'DD-MM-RRRR HH24:MI'),'FK Mlada Boleslav','FC Slovan Liberec', 000001, 'LOKOTRANS ARENA Mlada Boleslav');
INSERT INTO Zapas(zapas_id, datum, domaci, hoste, rozhodci_id, stadion_jmeno)
VALUES (000002, TO_TIMESTAMP('29-07-2023 14:00', 'DD-MM-RRRR HH24:MI'),'AC Sparta Praha','SK Slavia Praha',000002, 'epet ARENA');
INSERT INTO Zapas(zapas_id, datum, domaci, hoste, rozhodci_id, stadion_jmeno)
VALUES (000003, TO_TIMESTAMP('20-07-2023 10:00', 'DD-MM-RRRR HH24:MI'),'1.FC Slovacko','FK Teplice',000003,'Mestsky fotbalovy stadion Miroslava Valenty');
INSERT INTO Zapas(zapas_id,datum, domaci, hoste, rozhodci_id, stadion_jmeno)
VALUES (000004, TO_TIMESTAMP('18-08-2023 16:00', 'DD-MM-RRRR HH24:MI'),'AC Sparta Praha','FK Mlada Boleslav', 000004, 'epet ARENA');
INSERT INTO Zapas(zapas_id,datum, domaci, hoste, rozhodci_id, stadion_jmeno)
VALUES (000005, TO_TIMESTAMP('01-09-2023 15:00', 'DD-MM-RRRR HH24:MI'),'FC Slovan Liberec','1.FC Slovacko', 000001, 'Stadion U Nisy');
INSERT INTO Zapas(zapas_id,datum, domaci, hoste, rozhodci_id, stadion_jmeno)
VALUES (000006, TO_TIMESTAMP('2-08-2023 12:00', 'DD-MM-RRRR HH24:MI'),'SK Slavia Praha','FK Teplice', 000003, 'Fortuna Arena');
INSERT INTO Zapas(zapas_id,datum, domaci, hoste, rozhodci_id, stadion_jmeno)
VALUES (000007, TO_TIMESTAMP('11-09-2023 16:30', 'DD-MM-RRRR HH24:MI'),'FC Slovan Liberec','SK Slavia Praha', 000001, 'Stadion U Nisy');

COMMIT;


UPDATE Zapas
SET
    goly_domaci = 1,
    goly_hoste = 1,
    vitez = NULL,
    dohrano = 1
WHERE zapas_id = 000002;

UPDATE Zapas
SET
    goly_domaci = 2,
    goly_hoste = 0,
    vitez = '1.FC Slovacko',
    dohrano = 1
WHERE zapas_id = 000003;

COMMIT;

INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000011);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000012);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000013);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000014);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000015);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000001);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000002);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000003);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000004);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000002,00000005);

COMMIT;

INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000021);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000022);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000023);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000024);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000025);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000031);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000032);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000033);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000034);
INSERT INTO HracHraje(zapas_id,hrac_id) VALUES (000003,00000035);

COMMIT;

INSERT INTO HracScoruje(zapas_id,hrac_id,minuta) VALUES (000002,00000005,26);
INSERT INTO HracScoruje(zapas_id,hrac_id,minuta) VALUES (000002,00000014,74);

INSERT INTO HracScoruje(zapas_id,hrac_id,minuta) VALUES (000003,00000035,17);
INSERT INTO HracScoruje(zapas_id,hrac_id,minuta) VALUES (000003,00000034,62);

COMMIT;




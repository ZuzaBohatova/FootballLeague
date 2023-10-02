
-- Tema: Fotbalova Liga
-- Autor: Zuzana Bohatova
-- Model je najdete v souboru diagram.png

-- Obsahuje tabulky: hrac, tym, trener, stadion, zapas, rozhodci, a tabulky pro jednotlive vztahy
-- Hrac hraje za ejaky nebo zadny tym, a tym ma vice hracu. 
-- Tym ma 0 az n treneru a svuj stadion.
-- Kazdy zapas odehraly dva ruzne tymy a zapas mel rozhodciho a stadion. Hrac muze zapas hrat a muze v nem scorovat.

-- Nejprve spustit script Tabulky.sql, pote Nastroje.sql, az pote muzete provest insert dat pomoci scriptu Data.sql, a pak spustit dotazy v souboru Dotazy.sql


-- Stadion
CREATE TABLE Stadion (
    jmeno     VARCHAR2(255)
        CONSTRAINT Stadion_pk PRIMARY KEY,
    kapacita  NUMERIC(8, 0) NOT NULL
        CONSTRAINT Stadion_chk_kapacita CHECK(kapacita > 0),
    ulice         VARCHAR2(255) NOT NULL,
    cislo_popisne NUMERIC(6, 0) NOT NULL,
    mesto         VARCHAR2(255) NOT NULL,
    psc           NUMERIC(5, 0) NOT NULL,
    zeme          VARCHAR2(255) NOT NULL
);

-- Rozhodci
CREATE TABLE Rozhodci (
    rozhodci_id              NUMERIC(6, 0)
        CONSTRAINT Rozhodci_pk PRIMARY KEY,
    jmeno                    VARCHAR2(255) NOT NULL,
    pocet_odpiskanych_zapasu NUMERIC(6, 0) DEFAULT 0 NOT NULL
        CONSTRAINT Rozhodci_chk_pocet_odpiskanych_zapasu CHECK (pocet_odpiskanych_zapasu >= 0),
    narodnost                VARCHAR2(3) NOT NULL
);

-- Tym
CREATE TABLE Tym (
    jmeno         VARCHAR2(255)
        CONSTRAINT Tym_pk PRIMARY KEY,
    pocet_vyher   NUMERIC(2, 0) DEFAULT 0 NOT NULL
        CONSTRAINT Tym_chk_pocet_vyher CHECK ( pocet_vyher >= 0 ),
    pocet_proher  NUMERIC(2, 0) DEFAULT 0 NOT NULL
        CONSTRAINT Tym_chk_pocet_proher CHECK ( pocet_proher >= 0 ),
    pocet_remiz   NUMERIC(2, 0) DEFAULT 0 NOT NULL
        CONSTRAINT Tym_chk_pocet_remiz CHECK ( pocet_remiz >= 0 ),
    pocet_bodu    NUMERIC(3, 0) DEFAULT 0 NOT NULL
        CONSTRAINT Tym_chk_pocet_bodu CHECK ( pocet_bodu >= 0 ),
    goly_dal      NUMERIC(4, 0) DEFAULT 0 NOT NULL
        CONSTRAINT Tym_chk_goly_dal CHECK ( goly_dal >= 0 ),
    goly_dostal   NUMERIC(4, 0) DEFAULT 0 NOT NULL
        CONSTRAINT Tym_chk_goly_dostal CHECK ( goly_dostal >= 0 ),
    stadion_jmeno VARCHAR2(255),
    FOREIGN KEY ( stadion_jmeno )
        REFERENCES Stadion ( jmeno )
            ON DELETE SET NULL
);
-- Zapas
CREATE TABLE Zapas (
    zapas_id      NUMERIC(6, 0)
        CONSTRAINT Zapas_pk PRIMARY KEY,
    datum         TIMESTAMP NOT NULL,
    domaci        VARCHAR2(255) NOT NULL,
    hoste         VARCHAR2(255) NOT NULL,
    goly_domaci   NUMERIC(4, 0)
        CONSTRAINT Zapas_chk_goly_domaci CHECK ( goly_domaci >= 0 ),
    goly_hoste    NUMERIC(4, 0) 
        CONSTRAINT Zapas_chk_goly_hoste CHECK ( goly_hoste >= 0 ),
    vitez         VARCHAR2(255) DEFAULT NULL,
    -- pokud je vitez null a dohrano 1, zapas skoncil remizou
    dohrano       NUMERIC(1,0) DEFAULT 0 NOT NULL,
    rozhodci_id   NUMERIC(6, 0),
    stadion_jmeno VARCHAR2(255),
    FOREIGN KEY ( hoste )
        REFERENCES Tym ( jmeno )
            ON DELETE CASCADE,
    FOREIGN KEY ( domaci )
        REFERENCES Tym ( jmeno )
            ON DELETE CASCADE,
    FOREIGN KEY ( vitez )
        REFERENCES Tym ( jmeno )
            ON DELETE CASCADE,
    FOREIGN KEY ( rozhodci_id )
        REFERENCES Rozhodci ( rozhodci_id )
            ON DELETE SET NULL,
    FOREIGN KEY ( stadion_jmeno )
        REFERENCES Stadion ( jmeno )
            ON DELETE SET NULL
);

-- Trener
CREATE TABLE Trener (
    trener_id NUMERIC(6, 0)
        GENERATED ALWAYS AS IDENTITY
        CONSTRAINT Trener_pk PRIMARY KEY,
    jmeno     VARCHAR2(255) NOT NULL,
    narodnost VARCHAR2(3) NOT NULL,
    vek       NUMERIC(3, 0) NOT NULL
        CONSTRAINT Trener_chk_vek CHECK ( vek >= 18 ),
    tym_jmeno VARCHAR2(255),
    FOREIGN KEY ( tym_jmeno )
        REFERENCES Tym ( jmeno )
            ON DELETE SET NULL
);

-- Hrac
CREATE TABLE Hrac (
    hrac_id       NUMERIC(8, 0)
        CONSTRAINT Hrac_pk PRIMARY KEY,
    jmeno         VARCHAR2(255) NOT NULL,
    vek           NUMERIC(3, 0) NOT NULL
        CONSTRAINT Hrac_chk_vek CHECK ( vek > 14 ),
    pozice        VARCHAR2(255) NOT NULL,
    narodnost     VARCHAR2(3) NOT NULL,
    pocet_golu    NUMERIC(5, 0) DEFAULT 0 NOT NULL
        CONSTRAINT Hrac_chk_pocet_golu CHECK ( pocet_golu >= 0 ),
    tym_jmeno     VARCHAR2(255),
    FOREIGN KEY ( tym_jmeno )
        REFERENCES Tym ( jmeno )
            ON DELETE SET NULL
);

-- Vztah Hrac odehral zapas
CREATE TABLE HracHraje (
    hrac_id  NUMERIC(8, 0) NOT NULL,
    zapas_id NUMERIC(6, 0) NOT NULL,
    FOREIGN KEY ( hrac_id )
        REFERENCES Hrac ( hrac_id )
            ON DELETE CASCADE,
    FOREIGN KEY ( zapas_id )
        REFERENCES Zapas ( zapas_id )
            ON DELETE CASCADE,
    CONSTRAINT hrachraje_pk PRIMARY KEY(hrac_id,zapas_id)
);

-- Vztah hrac scoroval v zapase
CREATE TABLE HracScoruje (
    hrac_id  NUMERIC(8, 0) NOT NULL,
    zapas_id NUMERIC(6, 0) NOT NULL,
    minuta   NUMERIC(3,0) NOT NULL
        CONSTRAINT HracScoruje_chk_minuta CHECK (minuta > 0),
    FOREIGN KEY ( hrac_id )
        REFERENCES Hrac ( hrac_id )
            ON DELETE CASCADE,
    FOREIGN KEY ( zapas_id )
        REFERENCES Zapas ( zapas_id )
            ON DELETE CASCADE,
    CONSTRAINT hracscoruje_pk PRIMARY KEY(hrac_id,zapas_id,minuta)
);


-- Téma: Fotbalová liga
-- Autor: Zuzana Bohatová
-- Generování statistik

BEGIN
    FOR tab IN (SELECT table_name FROM all_tables WHERE owner = 'u8674125') LOOP
        DBMS_STATS.GATHER_TABLE_STATS('u86974125', tab.table_name);
    END LOOP;
END;
/


-- T�ma: Fotbalov� liga
-- Autor: Zuzana Bohatov�
-- Smaz�n� statistik

BEGIN
    FOR tab IN (SELECT table_name FROM all_tables WHERE owner = 'u86974125') LOOP
        DBMS_STATS.DELETE_TABLE_STATS('u86974125', tab.table_name);
    END LOOP;
END;
/
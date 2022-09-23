SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROCEDURE [dbo].[d_da_lgh_miles_ldmt_sp] 
	@lgh_number INTEGER 

AS 

SELECT @lgh_number lgh_number , 
       ISNULL( ( SELECT SUM( ISNULL( stp_lgh_mileage, 0 ) ) 
                  FROM stops 
                 WHERE stp_loadstatus = 'LD' AND 
                       lgh_number = @lgh_number ) 
       , 0 ) loaded_miles , 
       ISNULL( ( SELECT SUM( ISNULL( stp_lgh_mileage, 0 ) ) 
                   FROM stops 
                  WHERE ISNULL( stp_loadstatus, '' ) <> 'LD' AND 
                        lgh_number = @lgh_number ) 
       , 0 ) empty_miles , 
       ( SELECT TOP 1 cty_nmstct 
           FROM stops 
                JOIN city ON stp_city = cty_code 
          WHERE stp_mfh_sequence IN ( 
                ISNULL( ( 
                	SELECT MIN( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE ( stp_type = 'PUP' OR stp_event = 'XDL' ) AND 
                	       lgh_number = @lgh_number 
                ) , ( 
                	SELECT MIN( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE lgh_number = @lgh_number 
                ) ) ) AND 
                lgh_number = @lgh_number 
       ) first_loaded_citynmstct , 
       ( SELECT TOP 1 cty_nmstct 
           FROM stops 
                JOIN city ON stp_city = cty_code 
          WHERE stp_mfh_sequence IN ( 
                ISNULL( ( 
                	SELECT MAX( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE ( stp_type = 'DRP' OR stp_event = 'XDU' )  AND 
                	       lgh_number = @lgh_number 
                ) , ( 
                	SELECT MAX( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE lgh_number = @lgh_number 
                ) ) ) AND 
                lgh_number = @lgh_number 
       ) last_loaded_citynmstct , 
       ( SELECT TOP 1 cmp_id 
           FROM stops 
          WHERE stp_mfh_sequence IN ( 
                ISNULL( ( 
                	SELECT MIN( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE ( stp_type = 'PUP' OR stp_event = 'XDL' ) AND 
                	       lgh_number = @lgh_number 
                ) , ( 
                	SELECT MIN( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE lgh_number = @lgh_number 
                ) ) ) AND 
                lgh_number = @lgh_number 
       ) first_loaded_cmp_id , 
       ( SELECT TOP 1 cmp_id 
           FROM stops 
          WHERE stp_mfh_sequence IN ( 
                ISNULL( ( 
                	SELECT MAX( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE ( stp_type = 'DRP' OR stp_event = 'XDU' )  AND 
                	       lgh_number = @lgh_number 
                ) , ( 
                	SELECT MAX( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE lgh_number = @lgh_number 
                ) ) ) AND 
                lgh_number = @lgh_number 
       ) last_loaded_cmp_id , 
       ( SELECT TOP 1 company.cmp_name 
           FROM stops 
                JOIN company ON stops.cmp_id = company.cmp_id 
          WHERE stp_mfh_sequence IN ( 
                ISNULL( ( 
                	SELECT MIN( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE ( stp_type = 'PUP' OR stp_event = 'XDL' ) AND 
                	       lgh_number = @lgh_number 
                ) , ( 
                	SELECT MIN( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE lgh_number = @lgh_number 
                ) ) ) AND 
                lgh_number = @lgh_number 
       ) first_loaded_cmp_name , 
       ( SELECT TOP 1 company.cmp_name 
           FROM stops 
                JOIN company ON stops.cmp_id = company.cmp_id 
          WHERE stp_mfh_sequence IN ( 
                ISNULL( ( 
                	SELECT MAX( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE ( stp_type = 'DRP' OR stp_event = 'XDU' )  AND 
                	       lgh_number = @lgh_number 
                ) , ( 
                	SELECT MAX( stp_mfh_sequence ) 
                	  FROM stops 
                	 WHERE lgh_number = @lgh_number 
                ) ) ) AND 
                lgh_number = @lgh_number 
       ) last_loaded_cmp_name 

GO
GRANT EXECUTE ON  [dbo].[d_da_lgh_miles_ldmt_sp] TO [public]
GO

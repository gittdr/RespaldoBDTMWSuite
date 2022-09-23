SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


CREATE PROCEDURE [dbo].[d_ptc_detail_sp]	@ptc_origin		INTEGER,
					@ptc_destination	INTEGER
AS
CREATE TABLE #temp (
	ptc_origin	VARCHAR(6) NULL,
        ptc_destination VARCHAR(6) NULL,
        ptc_mode	VARCHAR(6) NULL,
        ptc_date	DATETIME NULL
)

INSERT INTO #temp
   SELECT ptc_origin, ptc_destination, ptc_mode, MAX(ptc_date)
     FROM purchase_transport_cost
    WHERE (@ptc_origin = 0 OR ptc_origin = @ptc_origin) AND
          (@ptc_destination = 0 OR ptc_destination = @ptc_destination)
GROUP BY ptc_origin, ptc_destination, ptc_mode
HAVING MAX(ptc_date) <= GETDATE()

SELECT a.ptc_id, 
       a.ptc_origin, 
       a.ptc_destination, 
       a.ptc_linehaul, 
       a.ptc_linehaul_permile, 
       a.ptc_fsc_table, 
       a.ptc_date, 
       a.ptc_amtover, 
       a.ptc_amtover_basis, 
       a.ptc_level, 
       a.ptc_locked, 
       a.ptc_minmargin, 
       a.ptc_minmargin_basis, 
       a.ptc_minmargin_locked, 
       a.ptc_mode, 
       a.ptc_updateddate, 
       a.ptc_updatedby
  FROM purchase_transport_cost a JOIN #temp ON a.ptc_origin = #temp.ptc_origin AND
                                               a.ptc_destination = #temp.ptc_destination AND
                                               a.ptc_mode = #temp.ptc_mode AND
                                               a.ptc_date = #temp.ptc_date

       
GO
GRANT EXECUTE ON  [dbo].[d_ptc_detail_sp] TO [public]
GO

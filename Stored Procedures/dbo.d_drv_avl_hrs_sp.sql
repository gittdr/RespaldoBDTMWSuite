SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_drv_avl_hrs_sp    Script Date: 6/1/99 11:54:09 AM ******/
-- create stored procedure */
CREATE PROC [dbo].[d_drv_avl_hrs_sp](@rowdate datetime, @drvr_id varchar(10))

AS

-- Begin of stored procedure d_drv_avl_hrs_sp */
BEGIN

--*****************************************************************/
--Declaration and initialization of variables*/

DECLARE  @char18        VarChar(8),	
         @vchar12       Varchar(12),
         @count_val     int,
         @v_drvr_id     Varchar(10),
         @v_days        int,
         @v_hours       int,
         @date_val      datetime,
         @min_dt        datetime,
         @prev_assgn_dt	datetime,
         @null_val      varchar(4),	
         @i             int,
         @avl_hours     real,
         @sum_hrs       real,
         @drv_hrs       real,
         @char15        real,
         @cur_name_srvcrule   varchar(20),	
         @cur_abbr_srvcrule   varchar(10)        
	


--Create temporary table for servicerule                           


          SELECT  labelfile.name  nm_srvcrule,
                  labelfile.abbr  abbr_srvcrule,
                  @char15         avl_hrs
          INTO  #temp
          FROM  labelfile
          WHERE labelfile.labeldefinition = 'ServiceRule'
          ORDER BY labelfile.abbr 

--Counts the number of service rules enetered
          SELECT  @count_val = count(*)
          FROM    #temp
		

          DECLARE srvcrules CURSOR FOR
          SELECT name, abbr
          FROM   labelfile
          WHERE	 labeldefinition = 'ServiceRule'	
          ORDER BY abbr
	
          OPEN  srvcrules
	
          FETCH	srvcrules INTO @cur_name_srvcrule, @cur_abbr_srvcrule
-- mss version 
--&&STARTMSSQL
	WHILE	(@@fetch_status = 0)
--&&ENDMSSQL
-- sybase version 
--&&STARTSYBASE
--	WHILE	(@@sqlstatus = 0 )	
--&&ENDSYBASE	
	BEGIN
              EXECUTE d_get_drvsrvrule_avlhr_sp @drvr_id, @cur_abbr_srvcrule, @rowdate, @avl_hours OUT
			
              IF (@avl_hours <> -100)
              BEGIN	     
                  UPDATE #temp
                  SET	avl_hrs = ROUND(@avl_hours, 2)
                  WHERE	nm_srvcrule = @cur_name_srvcrule
              END
	FETCH	srvcrules INTO @cur_name_srvcrule, @cur_abbr_srvcrule
	END
-- mss version 
--&&STARTMSSQL	
	DEALLOCATE srvcrules
--&&ENDMSSQL
-- sysbase version 
--&&STARTSYBASE
--	DEALLOCATE CURSOR srvcrules
--&&ENDSYBASE
-- end of stored procedure d_drv_avl_hrs_sp
END

	SELECT	nm_srvcrule, 
		abbr_srvcrule, 
		avl_hrs
	FROM 	#temp
	

GO
GRANT EXECUTE ON  [dbo].[d_drv_avl_hrs_sp] TO [public]
GO

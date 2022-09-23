SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_drv_avail_hrs_sp    Script Date: 6/1/99 11:54:03 AM ******/
CREATE PROCEDURE [dbo].[d_drv_avail_hrs_sp]

@driver_id	varchar(8),
@days		int,
@hours		int,
@hoursout       float (2) output /* will return hrs here */

AS

BEGIN

   DECLARE @v_day datetime, @today char(10), @v_date char(10), @min int
   DECLARE @load_time float, @unload_time float, @logged_time float
   DECLARE @drive_hrs float, @drive_time float, @tot_prod_hrs float
   DECLARE @load_hrs float, @unload_hrs float
   DECLARE @daysin int, @srule varchar(10), @sr_chr_day varchar(4), @sr_chr_hrs varchar(4)

   SELECT @tot_prod_hrs = 0
   SELECT @load_hrs = 0
   SELECT @unload_hrs = 0
   SELECT @drive_hrs = 0
   SELECT @load_time = 0
   SELECT @unload_time = 0
   SELECT @drive_time = 0

-- figure out the servicerule 
   SELECT @sr_chr_day = convert(varchar(4), @days)
   SELECT @sr_chr_hrs = convert(varchar(4), @hours)
   SELECT @srule = @sr_chr_day+ '/' + @sr_chr_hrs

   SELECT @daysin = @days - 1
   SELECT @days = (@days - 1) * -1
   SELECT @v_day = dateadd(day, @days, getdate())
   SELECT @v_date = convert(char(10), @v_day, 101)
   SELECT @today = convert(char(10), getdate(), 101)

 EXECUTE d_get_drvsrvrule_avlhr_sp @driver_id, @srule, @today, @hoursout OUT
    
 RETURN
END
/* commented out vj 01/31/97  RETURN */


GO
GRANT EXECUTE ON  [dbo].[d_drv_avail_hrs_sp] TO [public]
GO

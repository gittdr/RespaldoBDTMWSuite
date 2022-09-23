SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sv_import_kronos_sp] (@drv_altid varchar(9), 
				      @work_date datetime, 
				      @start_time varchar(5),
				      @end_time varchar(5)
				     )
AS

begin transaction
declare @in_time datetime, @out_time datetime
declare @colon_location int, @minutes int, @hour int

select @colon_location = charindex(':',@start_time)
IF @colon_location = 0
	RAISERROR('Validation Error.  In time does not contain a colon.',16,1)
ELSE
  begin
	select @hour = left(@start_time,@colon_location -1)
	select @minutes = substring(@start_time,@colon_location + 1,2)
	select @in_time = convert(datetime,'01/01/50 ' + convert(varchar(2),@hour) + ':' + convert(varchar(2),@minutes))
  end	
--reset the vars
select @colon_location = 0
select @hour = 0
select @minutes = 0

select @colon_location = charindex(':',@end_time)
IF @colon_location = 0
	RAISERROR('Validation Error.  Out time does not contain a colon.',16,1)
ELSE
  begin
	select @hour = left(@end_time,@colon_location -1)
	select @minutes = substring(@end_time,@colon_location + 1,2)
	select @out_time = convert(datetime,'01/01/50 ' + convert(varchar(2),@hour) + ':' + convert(varchar(2),@minutes))
  end	

--debug
--select @drv_altid'altid', @work_date'work_date', @in_time'in_time', @out_time'out_time'

insert into sv_kronos_import (drv_altid, work_date, in_time, out_time)
values (@drv_altid, @work_date, @in_time, @out_time)

IF @@error = 0
  COMMIT TRANSACTION
ELSE
  ROLLBACK

GO
GRANT EXECUTE ON  [dbo].[sv_import_kronos_sp] TO [public]
GO

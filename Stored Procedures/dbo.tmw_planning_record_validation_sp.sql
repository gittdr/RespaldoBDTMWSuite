SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[tmw_planning_record_validation_sp] (@shipper varchar(8), @cmd varchar(8), @ord_number varchar(12), @errmsg varchar(1024) OUTPUT)
AS
DECLARE @proctocall varchar(255),
  @sql nvarchar(1024)
select @errmsg = ''
SELECT  @proctocall = IsNull(gi_string1, '')
FROM generalinfo
WHERE gi_name = 'AGGPLANUPDATEPROC'
If @proctocall > '' 
 BEGIN
  SELECT @sql = 'exec ' + @proctocall + ' ''' + @shipper + ''', ' + ' ''' + @cmd + ''', ' + ' ''' + @ord_number + ''''
  exec @proctocall @shipper, @cmd, @ord_number, @errmsg OUTPUT
 END
GO
GRANT EXECUTE ON  [dbo].[tmw_planning_record_validation_sp] TO [public]
GO

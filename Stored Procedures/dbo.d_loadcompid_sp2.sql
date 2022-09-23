SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/****** Object:  Stored Procedure dbo.d_loadcompid_sp2    Script Date: 6/1/99 11:54:18 AM ******/
create PROC [dbo].[d_loadcompid_sp2] @comp varchar(8) , @number int AS

DECLARE @daysout int, @date datetime
SELECT @daysout = -90
SELECT @daysout = gi_integer1, 
		 @date = gi_date1 FROM generalinfo WHERE gi_name = 'GRACE'

if @number = 1 
	set rowcount 1 
else if @number <= 8 
	set rowcount 8
else if @number <= 16
	set rowcount 16
else if @number <= 24
	set rowcount 24
else
	set rowcount 8

if exists ( SELECT cmp_id FROM company WHERE cmp_id >= @comp ) 
	if @daysout = 999
		SELECT cmp_name ,
				 cmp_id ,
				 cmp_address1 ,
				 cmp_address2 , 
				 cty_nmstct,
				 cmp_defaultbillto,
				 cmp_defaultpriority
			FROM company 
			WHERE cmp_id >= @comp 
			ORDER BY cmp_id 
	else
		SELECT cmp_name ,
				 cmp_id ,
				 cmp_address1 ,
				 cmp_address2 , 
				 cty_nmstct,
				 cmp_defaultbillto,
				 cmp_defaultpriority
			FROM company 
			WHERE cmp_id >= @comp 
			AND (cmp_active = 'Y' OR cmp_active is null)
			ORDER BY cmp_id 

else 
	SELECT cmp_name ,
			cmp_id , 
			cmp_address1 , 
			cmp_address2 ,
			cty_nmstct ,

			cmp_defaultbillto,
			cmp_defaultpriority
  
		FROM company 
		WHERE cmp_id = 'UNKNOWN' 

set rowcount 0 




GO
GRANT EXECUTE ON  [dbo].[d_loadcompid_sp2] TO [public]
GO

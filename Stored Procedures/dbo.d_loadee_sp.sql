SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE PROC [dbo].[d_loadee_sp] @emp varchar(8) , @number int AS 
/* 
SR 17782 DPETE created 10/13/03  

*/

DECLARE @daysout int, @date datetime
SELECT @daysout = -90
--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
SELECT @daysout = gi_integer1, 
		 @date = gi_date1 FROM generalinfo WHERE gi_name = 'GRACE'
If @daysout <> 999 
	SELECT @date = dateadd (day, @daysout, getdate())


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

if exists ( SELECT ee_id FROM employeeprofile 
	WHERE ee_id LIKE @emp + '%') 
	SELECT empname = IsNull(ee_firstname,'')+' '+IsNull(ee_middleinit,'')+' '+IsNull(ee_lastname,''),
      ee_id
		FROM employeeprofile 
		WHERE ee_id LIKE @emp + '%'
	ORDER BY ee_id 
Else
	SELECT empname = IsNull(ee_firstname,'')+' '+IsNull(ee_middleinit,'')+' '+IsNull(ee_lastname,''),
      ee_id
		FROM employeeprofile 
		WHERE ee_id = 'UNKNOWN' 

set rowcount 0 



GO
GRANT EXECUTE ON  [dbo].[d_loadee_sp] TO [public]
GO

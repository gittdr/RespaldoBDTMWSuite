SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- create procedure
CREATE PROCEDURE [dbo].[d_loadpsgr_sp] @p_psgr varchar(8) , 
				@p_number INT 
AS

DECLARE @daysout INT, @date DATETIME

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


if @p_number = 1 
	set rowcount 1 
else if @p_number <= 8 
	set rowcount 8
else if @p_number <= 16
	set rowcount 16
else if @p_number <= 24
	set rowcount 24
else
	set rowcount 8

if exists ( SELECT psgr_id FROM passenger 
	WHERE psgr_id LIKE @p_psgr + '%') 
	SELECT psgrname = IsNull(psgr_firstname,'')+' '+IsNull(psgr_middleinitial,'')+' '+IsNull(psgr_lastname,''),
      psgr_id
		FROM passenger 
		WHERE psgr_id LIKE @p_psgr + '%'
	ORDER BY psgr_id 
Else
	SELECT psgrname = IsNull(psgr_firstname,'')+' '+IsNull(psgr_middleinitial,'')+' '+IsNull(psgr_lastname,''),
      psgr_id
		FROM passenger 
		WHERE psgr_id = 'UNKNOWN'

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadpsgr_sp] TO [public]
GO

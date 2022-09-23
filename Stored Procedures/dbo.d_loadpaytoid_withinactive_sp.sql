SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadpaytoid_withinactive_sp] @comp varchar(8) , @number int AS
/**
 * DESCRIPTION:
 *
 * REVISION HISTORY:
 * 10/26/2007.01 ? PTS40012 - JGUO ? convert old style outer join syntax to ansi outer join syntax.
 *
 **/

DECLARE @daysout int, @date datetime

--PTS 64250 JJF 20120808
DECLARE @rowsecurity	char(1)
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 64250 JJF 20120808


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

--PTS 64250 JJF 20120808
SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_payto_fn() 
END
--END PTS 64250 JJF 20120808

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

--PTS 51570 JJF 20100510 - add rowsec
--if exists ( SELECT pto_id FROM payto WHERE pto_id >= @comp ) 
if exists	(	SELECT	pto_id 
				FROM	payto 
						--PTS 64250 JJF 20120808
						--inner join RowRestrictValidAssignments_payto_fn() rsva on (payto.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						--END PTS 64250 JJF 20120808
				WHERE	pto_id like @comp + '%'		/* 08/05/2010 MDH PTS 52432: Changed to like */
						--PTS 64250 JJF 20120808
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE payto.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)
						--END PTS 64250 JJF 20120808

			)
	SELECT  isnull(case 
		       when len(pto_companyname) > 0 then pto_companyname
		       else pto_lastfirst
		       end,'') , 
		isnull(pto_id,'') , 
    		isnull(pto_address1,'') , 
		isnull(cty_nmstct,''),
		isnull(pto_companyname,''),
		isnull(cty_zip,'')				
	FROM    payto left outer join city on payto.pto_city = city.cty_code  --pts40012, jg, outer join conversion
			--PTS 64250 JJF 20120808
			--inner join RowRestrictValidAssignments_payto_fn() rsva on (payto.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
			--END PTS 64250 JJF 20120808
	WHERE   pto_id like @comp + '%' 		/* 08/05/2010 MDH PTS 52432: Changed to like */
			AND	(	pto_status <> 'OUT' 
					OR	(	pto_status = 'OUT' 
							AND pto_terminatedate >= @date
						)
				)
				--PTS 64250 JJF 20120808
				AND	(	(@rowsecurity <> 'Y')
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE payto.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				)
				--END PTS 64250 JJF 20120808

-- PTS 20163 -- BL (start)
	ORDER BY pto_id
-- PTS 20163 -- BL (end)

else 
	SELECT 
		case 
				when len(pto_companyname) > 0 then pto_companyname
			else pto_lastfirst
		end, 
		pto_id,
		pto_address1,
		'UNKNOWN',
		 '',''
		FROM payto
		WHERE pto_id = 'UNKNOWN' 

set rowcount 0 



GO
GRANT EXECUTE ON  [dbo].[d_loadpaytoid_withinactive_sp] TO [public]
GO

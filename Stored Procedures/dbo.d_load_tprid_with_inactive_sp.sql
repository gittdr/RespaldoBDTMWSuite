SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROC [dbo].[d_load_tprid_with_inactive_sp] @tprid varchar(8) , @number int AS

DECLARE @daysout int, @match_rows int, @date datetime

--PTS 64250 JJF 20120808
DECLARE @rowsecurity	char(1)
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 64250 JJF 20120808

SELECT  @daysout = -90
--vjh 31536
if exists ( SELECT lbp_id FROM ListBoxProperty where lbp_id=@@spid)
select @daysout = lbp_daysout, 
	@date = lbp_date
	from ListBoxProperty
	where lbp_id=@@spid
else
SELECT  @daysout = gi_integer1, 
        @date = gi_date1 
  FROM generalinfo 
 WHERE gi_name = 'GRACE'

--PTS 64250 JJF 20120808
SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'

IF @rowsecurity = 'Y' BEGIN
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_thirdpartyprofile_fn() 
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


if @daysout = 999
	--PTS 51570 JJF 20100510 - add rowsec
	if exists	(	SELECT	tpr_name 
					FROM	thirdpartyprofile 
							--PTS 64250 JJF 20120808
							--inner join RowRestrictValidAssignments_thirdpartyprofile_fn() rsva on (thirdpartyprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							--END PTS 64250 JJF 20120808
					WHERE	tpr_id LIKE @tprid + '%'
							--PTS 64250 JJF 20120808
							AND	(	(@rowsecurity <> 'Y')
									OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE thirdpartyprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
							--END PTS 64250 JJF 20120808
				)
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0
else
	if exists	(	SELECT	tpr_name 
					FROM	thirdpartyprofile 
							--PTS 64250 JJF 20120808
							--inner join RowRestrictValidAssignments_thirdpartyprofile_fn() rsva on (thirdpartyprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							--END PTS 64250 JJF 20120808
					WHERE	tpr_id LIKE @tprid + '%'
							--PTS 64250 JJF 20120808
							AND	(	(@rowsecurity <> 'Y')
									OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE thirdpartyprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
							)
							--END PTS 64250 JJF 20120808

				)
				
		SELECT @match_rows = 1
	else
		SELECT @match_rows = 0



if @match_rows > 0
	if @daysout = 999
		--PTS 51570 JJF 20100510 - add rowsec
		SELECT tpr_name, 
                       tpr_id, 
                       tpr_address1, 
                       tpr_address2, 
                       tpr_cty_nmstct, 
                       ISNULL(tpr_zip, ''), 
                       tpr_thirdpartytype1, 
                       tpr_thirdpartytype2, 
                       tpr_thirdpartytype3, 
                       tpr_thirdpartytype4, 
                       tpr_thirdpartytype5, 
                       tpr_thirdpartytype6 
                  FROM thirdpartyprofile 
						--PTS 64250 JJF 20120808
						--inner join RowRestrictValidAssignments_thirdpartyprofile_fn() rsva on (thirdpartyprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						--END PTS 64250 JJF 20120808
                 WHERE tpr_id LIKE @tprid + '%'
						--PTS 64250 JJF 20120808
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE thirdpartyprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)
						--END PTS 64250 JJF 20120808

              ORDER BY tpr_id 
	else
		SELECT tpr_name, 
                       tpr_id, 
                       tpr_address1, 
                       tpr_address2, 
                       tpr_cty_nmstct, 
                       ISNULL(tpr_zip, ''), 
                       tpr_thirdpartytype1, 
                       tpr_thirdpartytype2, 
                       tpr_thirdpartytype3, 
                       tpr_thirdpartytype4, 
                       tpr_thirdpartytype5, 
                       tpr_thirdpartytype6 
                  FROM thirdpartyprofile 
						--PTS 64250 JJF 20120808
						--inner join RowRestrictValidAssignments_thirdpartyprofile_fn() rsva on (thirdpartyprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						--END PTS 64250 JJF 20120808
                 WHERE tpr_id LIKE @tprid + '%' 
						--PTS 64250 JJF 20120808
						AND	(	(@rowsecurity <> 'Y')
								OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE thirdpartyprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)
						--END PTS 64250 JJF 20120808

              ORDER BY tpr_id 

else 
	SELECT tpr_name, 
               tpr_id, 
               tpr_address1, 
               tpr_address2, 
               tpr_cty_nmstct, 
               tpr_zip, 
               tpr_thirdpartytype1, 
               tpr_thirdpartytype2, 
               tpr_thirdpartytype3, 
               tpr_thirdpartytype4, 
               tpr_thirdpartytype5, 
               tpr_thirdpartytype6 
          FROM thirdpartyprofile 
         WHERE tpr_id = 'UNKNOWN' 

set rowcount 0 



GO
GRANT EXECUTE ON  [dbo].[d_load_tprid_with_inactive_sp] TO [public]
GO

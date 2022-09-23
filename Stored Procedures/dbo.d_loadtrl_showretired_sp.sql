SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadtrl_showretired_sp] @trl varchar(13) , @number int AS

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1)
--END PTS 42816 JJF 20080527			

--PTS 53255 JJF 20101130
--PTS 42816 JJF 20080527
--DECLARE @tbl_trlrestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--PTS 53255 JJF 20101130

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'


IF @rowsecurity = 'Y' BEGIN
	--PTS 53255 JJF 20101130
	--INSERT INTO @tbl_trlrestrictedbyuser
	--SELECT * FROM  rowrestrictbyuser_trailer_fn(@trL)
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_trailerprofile_fn() 
	--END PTS 53255 JJF 20101130
END
--END PTS 42816 JJF 20080527

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

if exists ( SELECT trl_id 
			FROM trailerprofile 
			WHERE trl_id LIKE @trl + '%' 
					--PTS 42816 JJF 20080527
					--PTS 53255 JJF 20101130
					--AND (EXISTS(select * FROM @tbl_trlrestrictedbyuser trlres WHERE trailerprofile.trl_number = trlres.value)
					--	OR @rowsecurity <> 'Y')
					AND	(	(@rowsecurity <> 'Y')
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE trailerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
					)
					--END PTS 53255 JJF 20101130
					--END PTS 42816 JJF 20080527
			)
	SELECT trl_id, trl_status 
		FROM trailerprofile 
		WHERE trl_id LIKE @trl + '%'
					--PTS 42816 JJF 20080527
					--PTS 53255 JJF 20101130
					--AND (EXISTS(select * FROM @tbl_trlrestrictedbyuser trlres WHERE trailerprofile.trl_number = trlres.value)
					--	OR @rowsecurity <> 'Y')
					AND	(	(@rowsecurity <> 'Y')
						OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE trailerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
					)
					--END PTS 53255 JJF 20101130
					--END PTS 42816 JJF 20080527
	ORDER BY trl_id
else 
	SELECT trl_id, trl_status
		FROM trailerprofile 
		WHERE trl_id = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadtrl_showretired_sp] TO [public]
GO

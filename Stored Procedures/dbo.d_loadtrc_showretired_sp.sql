SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loadtrc_showretired_sp] @trc varchar(8) , @number int, @parmlist varchar(254) AS

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1)
--END PTS 42816 JJF 20080527			
--PTS 52889 JJF 20101028
DECLARE	@RowSecurityCustom char(1)
DECLARE	@RowSecurityCustomOverride char(1)
--END PTS 42816 JJF 20080527			

--PTS 42816 JJF 20080527
--PTS 53255 JJF 20101130
--DECLARE @tbl_trcrestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--PTS 53255 JJF 20101130
--PTS 52889 JJF 20101028
DECLARE @tbl_restrictedcustom TABLE(Value VARCHAR(8))

SELECT @RowSecurityCustom = gi_string1,
		@RowSecurityCustomOverride = gi_string2
FROM generalinfo 
WHERE gi_name = 'RowSecurityCustom'

IF @RowSecurityCustom = 'Y' BEGIN
	IF @RowSecurityCustomOverride = 'Y' BEGIN
		SELECT *
		 FROM  d_loadtrc_custom_fn(@trc, @number, @parmlist)

		IF @@ROWCOUNT > 0 BEGIN
			RETURN
		END
	END
	
	INSERT INTO @tbl_restrictedcustom
	SELECT * FROM  rowrestrict_tractor_fn(@trc, 'DropDownLookup1004', @parmlist)
END
--PTS 52889 JJF 20101028

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'


IF @rowsecurity = 'Y' BEGIN
	--PTS 53255 JJF 20101130
	--INSERT INTO @tbl_trcrestrictedbyuser
	--SELECT * FROM  rowrestrictbyuser_tractor_fn(@trc)
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_tractorprofile_fn() 
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

if exists ( SELECT trc_number 
			FROM tractorprofile 
			WHERE trc_number LIKE @trc + '%'
					--PTS 53255 JJF 20101130
					AND	(	(@rowsecurity <> 'Y')
							OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE tractorprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
						)
					--AND (EXISTS(select * FROM @tbl_trcrestrictedbyuser trcres WHERE tractorprofile.trc_number = trcres.value)
					--	OR @rowsecurity <> 'Y')
					--END PTS 53255 JJF 20101130
					--PTS 52889 JJF 20101028
					AND (EXISTS(select * FROM @tbl_restrictedcustom rr WHERE tractorprofile.trc_number = rr.value)
						OR @RowSecurityCustom <> 'Y')
					--END PTS 52889 JJF 20101028
			)
	SELECT trc_number, trc_status
	FROM tractorprofile 
	WHERE trc_number LIKE @trc + '%' 
			--PTS 53255 JJF 20101130
			AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE tractorprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				)
			--AND (EXISTS(select * FROM @tbl_trcrestrictedbyuser trcres WHERE tractorprofile.trc_number = trcres.value)
			--	OR @rowsecurity <> 'Y')
			--END PTS 53255 JJF 20101130
			--PTS 52889 JJF 20101028
			AND (EXISTS(select * FROM @tbl_restrictedcustom rr WHERE tractorprofile.trc_number = rr.value)
				OR @RowSecurityCustom <> 'Y')
			--END PTS 52889 JJF 20101028
	ORDER BY trc_number 
else 
	SELECT trc_number, trc_status
	FROM tractorprofile 
	WHERE trc_number = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loadtrc_showretired_sp] TO [public]
GO

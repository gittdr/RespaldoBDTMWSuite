SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[d_loaddrvid_showretired_sp] @drv varchar(8) , @number int AS

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1)
--END PTS 42816 JJF 20080527			

--PTS 53255 JJF 20101130
--PTS 42816 JJF 20080527
--DECLARE @tbl_drvrestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 53255 JJF 20101130

SELECT @rowsecurity = gi_string1
FROM generalinfo 
WHERE gi_name = 'RowSecurity'


IF @rowsecurity = 'Y' BEGIN
	--PTS 53255 JJF 20101130
	--INSERT INTO @tbl_drvrestrictedbyuser
	--SELECT * FROM  rowrestrictbyuser_driver_fn(@emp)
	INSERT INTO @tbl_restrictedbyuser
	SELECT rowsec_rsrv_id FROM RowRestrictValidAssignments_manpowerprofile_fn() 
	--PTS 53255 JJF 20101130
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

if exists ( SELECT mpp_id FROM manpowerprofile 
            WHERE mpp_id LIKE @drv + '%'
			--PTS 53255 JJF 20101130
			--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
			--	OR @rowsecurity <> 'Y')
			AND	(	(@rowsecurity <> 'Y')
				OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
			)
			--END PTS 53255 JJF 20101130
			--END PTS 42816 JJF 20080527
			)

            SELECT mpp.mpp_lastfirst, mpp.mpp_id, mpp.mpp_otherid, mpp.mpp_status,
            	--PTS 64927 JJF 20130709
				ISNULL(mpp.mpp_address1, '') as mpp_address1,
				ISNULL(mpp.mpp_address2, '') as mpp_address2,
				ISNULL(cty.cty_nmstct, '') as cty_nmstct,
				mpp.mpp_currentphone,
				mpp.mpp_type1,
				mpp.mpp_type2,
				mpp.mpp_type3,
				mpp.mpp_type4
				--END PTS 64927 JJF 20130709
			FROM	manpowerprofile mpp with (nolock)
			inner join city cty with (nolock) on mpp.mpp_city = cty.cty_code
            WHERE mpp.mpp_id LIKE @drv + '%'
				--PTS 42816 JJF 20080527
				--PTS 53255 JJF 20101130
				--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
				--	OR @rowsecurity <> 'Y')
				AND	(	(@rowsecurity <> 'Y')
					OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
				)
				--END PTS 53255 JJF 20101130
				--END PTS 42816 JJF 20080527
            ORDER BY mpp_id 
Else
	SELECT mpp_lastfirst , mpp_id, mpp_otherid, mpp_status,
    	--PTS 64927 JJF 20130709
		'' as mpp_address1,
		'' as mpp_address2,
		'' as cty_nmstct,
		mpp_currentphone,
		mpp_type1,
		mpp_type2,
		mpp_type3,
		mpp_type4
		--END PTS 64927 JJF 20130709
	FROM manpowerprofile 
	WHERE mpp_id = 'UNKNOWN' 

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loaddrvid_showretired_sp] TO [public]
GO

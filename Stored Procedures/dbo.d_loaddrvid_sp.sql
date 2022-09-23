SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--PTS 38816 JJF 20080311 add parmlist
CREATE PROC [dbo].[d_loaddrvid_sp] @drv varchar(8) , @number int, @parmlist varchar(254) AS

DECLARE @daysout int, @date datetime
DECLARE @v_string1 char(1), @v_string2 char(1), @v_string3 char(1), @v_string4 char(1)
select	@v_string1 = isnull(gi_string1,'N'),
		@v_string2 = isnull(gi_string2,'N'),
		@v_string3 = isnull(gi_string3,'N'),
		@v_string4 = isnull(gi_string4,'N')
from generalinfo where gi_name = 'driverdropdowncontrol'

--PTS 42816 JJF 20080527
DECLARE @rowsecurity	char(1),
		@RowSecurityCustom char(1),
		@RowSecurityCustomOverride char(1)
--END PTS 42816 JJF 20080527			

--PTS 53255 JJF 20101130
--PTS 42816 JJF 20080527
--DECLARE @tbl_drvrestrictedbyuser TABLE(Value VARCHAR(8))
DECLARE @tbl_restrictedbyuser TABLE(rowsec_rsrv_id int primary key)
--END PTS 53255 JJF 20101130
DECLARE @tbl_drvrestrictedcustom TABLE(Value VARCHAR(8))

SELECT @RowSecurityCustom = gi_string1,
		@RowSecurityCustomOverride = gi_string2
FROM generalinfo 
WHERE gi_name = 'RowSecurityCustom'

IF @RowSecurityCustom = 'Y' BEGIN
	IF @RowSecurityCustomOverride = 'Y' BEGIN
		SELECT *
		 FROM  d_loaddrvid_custom_fn(@drv, @number, @parmlist)

		IF @@ROWCOUNT > 0 BEGIN
			RETURN
		END
	END

	INSERT INTO @tbl_drvrestrictedcustom
	SELECT * FROM  rowrestrict_driver_fn(@drv, 'DropDownLookup1003', @parmlist)
END 


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

if exists ( SELECT mpp_id FROM manpowerprofile 
	WHERE mpp_id LIKE @drv + '%'
		AND (mpp_status <> 'OUT' OR (mpp_status = 'OUT' AND mpp_terminationdt >= @date))
		AND mpp_status <> 'END'
		--PTS 42816 JJF 20080527
		--PTS 53255 JJF 20101130
		--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
		--	OR @rowsecurity <> 'Y')
		AND	(	(@rowsecurity <> 'Y')
			OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		)
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_drvrestrictedcustom cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
			OR @RowSecurityCustom <> 'Y')
		--END PTS 42816 JJF 20080527
	)




	SELECT mpp.mpp_lastfirst, mpp.mpp_id, mpp.mpp_otherid,
		rtrim(
			case @v_string1 when 'Y' then mpp.mpp_type1 + ' ' else '' end + 
			case @v_string2 when 'Y' then mpp.mpp_type2 + ' ' else '' end + 
			case @v_string3 when 'Y' then mpp.mpp_type3 + ' ' else '' end + 
			case @v_string4 when 'Y' then mpp.mpp_type4 else '' end
		) 'drivertypes',
		--PTS 64927 JJF 20130709
		ISNULL(mpp.mpp_address1, '') as mpp_address1,
		ISNULL(mpp.mpp_address2, '') as mpp_address2,
		ISNULL(cty.cty_nmstct, '') as cty_nmstct,
		mpp.mpp_currentphone
		--END PTS 64927 JJF 20130709
		FROM	manpowerprofile mpp with (nolock)
				inner join city cty with (nolock) on mpp.mpp_city = cty.cty_code
		WHERE mpp.mpp_id LIKE @drv + '%'
		AND (mpp.mpp_status <> 'OUT' OR (mpp.mpp_status = 'OUT' AND 
			mpp.mpp_terminationdt >= @date))
		AND mpp.mpp_status <> 'END'
		--PTS 42816 JJF 20080527
		--PTS 53255 JJF 20101130
		--AND (EXISTS(select * FROM @tbl_drvrestrictedbyuser cmpres WHERE manpowerprofile.mpp_id = cmpres.value)
		--	OR @rowsecurity <> 'Y')
		AND	(	(@rowsecurity <> 'Y')
			OR EXISTS(select * FROM @tbl_restrictedbyuser rsva WHERE mpp.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)
		)
		--END PTS 53255 JJF 20101130
		AND (EXISTS(select * FROM @tbl_drvrestrictedcustom cmpres WHERE mpp.mpp_id = cmpres.value)
			OR @RowSecurityCustom <> 'Y')
		--END PTS 42816 JJF 20080527
	ORDER BY mpp_id 
Else
	SELECT mpp_lastfirst , mpp_id, mpp_otherid, '',
		--PTS 64927 JJF 20130709
		'' as mpp_address1,
		'' as mpp_address2,
		'' as cty_nmstct,
		mpp_currentphone
		--END PTS 64927 JJF 20130709
		FROM manpowerprofile 
		WHERE mpp_id = 'UNKNOWN' 

		print @drv
		print @date

set rowcount 0 

GO
GRANT EXECUTE ON  [dbo].[d_loaddrvid_sp] TO [public]
GO

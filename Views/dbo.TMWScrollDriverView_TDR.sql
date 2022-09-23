SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [dbo].[TMWScrollDriverView_TDR] AS
SELECT
mpp_id,
mpp_lastname,
mpp_firstname,
mpp_middlename,
mpp_lastfirst,
mpp_status,    -- Include Retired Drivers and Driver Status
mpp_otherid, 
mpp_tractornumber, 
mpp_type1,	 --------CalifRemolque	
mpp_type2,   --------Rango
mpp_type3,   --------ProyectoDriver
mpp_type4,
mpp_misc1,
mpp_misc2,
mpp_misc3,
mpp_misc4,
mpp_qualificationlist,
PlannedCity.cty_nmstct,
AvailableCity.cty_state,
mpp_zip,
AvailableCity.cty_county,
mpp_company,
mpp_prior_region1,
mpp_prior_region2,
mpp_prior_region3,
mpp_prior_region4,
mpp_terminal,
mpp_division,
mpp_teamleader,
mpp_fleet,
mpp_gps_latitude,
mpp_gps_longitude*-1 as 'mpp_gps_longitude',
ISNULL(mpp_exp1_date,'12/31/49') as mpp_exp1_date,
ISNULL(mpp_exp2_date,'12/31/49') as mpp_exp2_date,
mpp_avl_date,
mpp_last_home,
mpp_want_home,
mpp_domicile,
mpp_state,
mpp_hiredate,--PTS 65119 - DJM
----------------------------------------------------------------------Modificado------------------------------------------------------------------
mpp_password as PassConvoy,
mpp_gps_heading as ConvoyUse,
mpp_licensenumber,
rtrim(mpp_id) +':' +rtrim(mpp_firstname) +' '+ rtrim(mpp_lastname) as Driver, 
cast(datepart(hh,mpp_avl_date) as int) as fecha,
DATEDIFF(dd, mpp_avl_date, GETDATE()) AS DIFDIAS,
CASE WHEN mpp_status IN ('AVL','PLN') THEN 0 ELSE DATEDIFF(dd, mpp_avl_date, GETDATE()) END AS DIAS,
mpp_licenseclass,     --------Licencia
(select name from labelfile with (nolock)  where labeldefinition = 'TeamLeader' and abbr = mpp_teamLeader) as nameTeamLeader,    -------Lider
(select cast(trc_gps_date as varchar(20)) + ' - ' + trc_gps_desc  from tractorprofile  where trc_number = mpp_tractornumber )as GPS,
mpp_avl_cmp_id AS Patio, 
(select rgh_name from regionheader with (nolock) where rgh_id  = (select cmp_region1  from company where company.cmp_id = mpp_avl_cmp_id)) as Region,
(select name from labelfile with (nolock)  where labeldefinition = 'DrvType3' and abbr = mpp_type3) as NombreProyecto,
mpp_mile_day7,        -----------Prodsietedias,
(select name from labelfile with (nolock)  where labeldefinition = 'RevType3' and abbr =(select cmp_revtype3 from company with (nolock)  where  CMP_ID = mpp_avl_cmp_id)) AS Proyecto
--------------------------------------------------------------------------------------------------------------------------------------------------
FROM dbo.manpowerprofile with (NOLOCK) 
	INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('manpowerprofile', null) rsva ON (manpowerprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0) 
	LEFT OUTER JOIN dbo.city (NOLOCK) ON dbo.manpowerprofile.mpp_city = dbo.city.cty_code 
	LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.manpowerprofile.mpp_avl_city = AvailableCity.cty_code 
	LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.manpowerprofile.mpp_pln_city = PlannedCity.cty_code
WHERE     (mpp_status not in ('OUT')) 
GO

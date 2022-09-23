SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE view [dbo].[TMWScrollTractorView_TDR] AS
SELECT 
trc_number, 
trc_type1,
trc_driver,
trc_status,
trc_company,
trc_terminal,
trc_division,
trc_owner,
trc_fleet,
(SELECT name FROM labelfile WHERE labeldefinition = 'Fleet' AND abbr=trc_fleet) AS FleetName,
format(trc_gps_date,'dd-MM-yyyy HH:mm:ss') + ' | ' + trc_gps_desc AS GPS,
trc_avl_date  avldate,
trc_next_event as nextevent,
trc_next_cmp_id as nextcomp,
trc_next_stoparrival as fechaprox,
trc_next_region1 as proxregion1,
(select cty_nmstct from city where cty_code = trc_next_city) as proxciudad,
trc_next_state as proxestado,
------ Modificado ---------------------------------------------------------------------------------------------------------------------------------------------------------------
DATEDIFF(dd, trc_avl_date, GETDATE()) AS DIAS,
CASE WHEN trc_driver = 'UNKNOWN' THEN 'Unseated' ELSE 'Seated' END AS Asignacion,
CASE 
	WHEN dbo.tractorprofile.trc_status = 'PLN'
	THEN 
	(select 'Segmento Planeado: ' + cast(max(lgh_number) as varchar(20)) from legheader where lgh_outstatus = 'PLN' and lgh_tractor = dbo.tractorprofile.trc_number)
	WHEN dbo.tractorprofile.trc_status = 'USE'
	THEN 
	(select 'Segmento Iniciado: ' + cast(max(lgh_number) as varchar(20)) from legheader where lgh_outstatus = 'STD' and lgh_tractor = dbo.tractorprofile.trc_number)
	ELSE
	ISNULL 
	((SELECT  MAX(exp_description) AS Expr1 FROM            dbo.expiration  WHERE        (exp_idtype = 'TRC') AND 
	(exp_id = dbo.tractorprofile.trc_number) AND (exp_completed <> 'Y') AND ( replace(exp_code,'SALV','INSHOP') = dbo.tractorprofile.trc_status)), 'NA')  end AS StatusDesc,
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
trc_licstate,
trc_licnum,
trc_serial,
trc_model,  
trc_make, 
trc_year, 
trc_type2,
trc_type3,
trc_type4,
trc_misc1,
trc_misc2,
trc_misc3,
trc_misc4,
PlannedCity.cty_nmstct, 
AvailableCity.cty_state,
AvailableCity.cty_zip, 
AvailableCity.cty_county, 
trc_avl_cmp_id,
trc_prior_region1,
trc_prior_region2,
trc_prior_region3,
trc_prior_region4,
trc_gps_latitude,
trc_gps_longitude*-1 as 'trc_gps_longitude',
ISNULL(trc_exp1_date,'12/31/49') as 'trc_exp1_date',
ISNULL(trc_exp2_date,'12/31/49') as 'trc_exp2_date',
trc_driver2,
trc_engineserial

FROM	dbo.tractorprofile (NOLOCK)
		INNER JOIN dbo.RowRestrictValidAssignments_for_tmwuser_fn_NET('tractorprofile', null) rsva ON (tractorprofile.rowsec_rsrv_id = rsva.rowsec_rsrv_id or rsva.rowsec_rsrv_id = 0)  
		LEFT OUTER JOIN dbo.city AvailableCity (NOLOCK) ON dbo.tractorprofile.trc_avl_city = AvailableCity.cty_code 
		LEFT OUTER JOIN dbo.city PlannedCity (NOLOCK) ON dbo.tractorprofile.trc_pln_city = PlannedCity.cty_code 
						


GO

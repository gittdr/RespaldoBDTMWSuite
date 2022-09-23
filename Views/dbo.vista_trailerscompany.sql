SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vista_trailerscompany]
AS
SELECT   
   trl_number AS Trailer, 
   trl_avail_date AS Fecha,
   DATEDIFF(dd, trl_avail_date, GETDATE()) AS DIFDIAS, 
   DATEDIFF(dd, trl_avail_date, GETDATE()) AS DIAS,
   trl_owner AS 'dueno',
   (SELECT  name FROM   dbo.labelfile WITH (nolock) WHERE        (labeldefinition = 'Fleet') AND (abbr = dbo.trailerprofile.trl_fleet)) AS FLOTA,

   (SELECT  name FROM  dbo.labelfile AS labelfile_2 WITH (nolock)  WHERE (labeldefinition = 'trlstatus') AND (abbr = dbo.trailerprofile.trl_status)) AS StatusTractor, 

	case 
	when dbo.trailerprofile.trl_status = 'PLN'
	then 
	(select 'Segmento Planeado: ' + cast(max(lgh_number) as varchar(20)) from legheader where lgh_outstatus = 'PLN' and lgh_tractor = dbo.trailerprofile.trl_number)
	when dbo.trailerprofile.trl_status = 'USE'
	then 
	(select 'Segmento Iniciado: ' + cast(max(lgh_number) as varchar(20)) from legheader where lgh_outstatus = 'STD' and lgh_tractor = dbo.trailerprofile.trl_number)
	else
	ISNULL 
	((SELECT  MAX(exp_description) AS Expr1 FROM            dbo.expiration  WHERE        (exp_idtype = 'trl') AND 
	(exp_id = dbo.trailerprofile.trl_number) AND (exp_completed <> 'Y') AND ( replace(exp_code,'SALV','INSHOP') = dbo.trailerprofile.trl_status)), 'NA')  end AS StatusDesc,
	
	trl_avail_cmp_id AS Patio,
	
	--CASE WHEN trl_driver = 'UNKNOWN' THEN 'Unseated' ELSE 'Seated' END AS Asignacion,
	
	RTRIM(trl_gps_desc) + ' (' + RTRIM(trl_gps_date) AS Ultpos,
    
	(SELECT  rgh_name FROM  dbo.regionheader WITH (nolock)  WHERE        (rgh_id = (SELECT        cmp_region1    FROM            dbo.company  
	WHERE        (cmp_id = dbo.trailerprofile.trl_avail_cmp_id)))) AS Region,

    --(SELECT mpp_id + ':' + mpp_firstname + ' ' + mpp_lastname AS Expr1  FROM  dbo.manpowerprofile  WHERE (mpp_id = dbo.trailerprofile.trl_driver)) AS Driver,

    (SELECT name  FROM  dbo.labelfile AS labelfile_1 WITH (nolock)  WHERE        (labeldefinition = 'RevType3') AND (abbr =
    (SELECT cmp_revtype3  FROM            dbo.company AS company_1 WITH (nolock) WHERE        (cmp_id = dbo.trailerprofile.trl_avail_cmp_id)))) AS Proyecto,

    (SELECT name  FROM   dbo.labelfile AS labelfile_1 WITH (nolock)  WHERE     
	(labeldefinition = 'RevType3') AND (abbr = dbo.trailerprofile.trl_type3)) AS DescProytrl, trl_type3 AS Proytrl, trl_owner AS propietario

    --(SELECT name  FROM            dbo.labelfile AS labelfile_3 WITH (nolock)  WHERE 
	--(labeldefinition = 'TeamLeader') 
	--AND (abbr = dbo.trailerprofile.trl_teamleader)) AS lider

FROM            dbo.trailerprofile WITH (nolock)
WHERE        (trl_status NOT IN ('OUT')) AND (trl_number <> 'UNKNOWN') 
--and trl_owner = 'TDR'

GO

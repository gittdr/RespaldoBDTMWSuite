SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[tmail_trailer_info] (@trl_id varchar(13)) 

AS

SET NOCOUNT ON 

/* For Testing 
DECLARE @trl_id varchar(13)
SET @trl_id = '03136'
--select * from #t
--drop table #t */

SELECT  @trl_id TrailerID, 
	ISNULL(trl_grosswgt,0) GrossWeight,
	ISNULL(trl_licnum,'') LicenseNumber,
	ISNULL(trl_licstate,'') LicenseState,
	ISNULL(trl_make,'') Make,		--5

	ISNULL(trl_model,'') Model,
	CONVERT(varchar(20),ISNULL(trl_type1,'')) TrailerType1,
	CONVERT(varchar(20),ISNULL(trl_type2,'')) TrailerType2,
	CONVERT(varchar(20),ISNULL(trl_type3,'')) TrailerType3,
	CONVERT(varchar(20),ISNULL(trl_type4,'')) TrailerType4	--10
INTO #t
FROM trailerprofile (NOLOCK) 
WHERE trl_id = @trl_id

-- Replace the trailer type abbreviation with the actual description.
UPDATE #t
SET TrailerType1 = Name 
FROM labelfile (NOLOCK)
WHERE labelfile.labeldefinition = 'trltype1' 
  AND labelfile.abbr = #t.TrailerType1

UPDATE #t
SET TrailerType2 = Name 
FROM labelfile (NOLOCK)
WHERE labelfile.labeldefinition = 'trltype2' 
  AND labelfile.abbr = #t.TrailerType2

UPDATE #t
SET TrailerType3 = Name 
FROM labelfile (NOLOCK)
WHERE labelfile.labeldefinition = 'trltype3' 
  AND labelfile.abbr = #t.TrailerType3

UPDATE #t
SET TrailerType4 = Name 
FROM labelfile (NOLOCK)
WHERE labelfile.labeldefinition = 'trltype4' 
  AND labelfile.abbr = #t.TrailerType4

-- Return the result set
SELECT  TrailerID, 
	GrossWeight,
	LicenseNumber,
	LicenseState,
	Make,	
	Model,
	TrailerType1,
	TrailerType2,
	TrailerType3,
	TrailerType4	
FROM #t
GO
GRANT EXECUTE ON  [dbo].[tmail_trailer_info] TO [public]
GO

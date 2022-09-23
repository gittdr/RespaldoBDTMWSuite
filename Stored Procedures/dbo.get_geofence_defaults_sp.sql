SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[get_geofence_defaults_sp] @cmp_id varchar(8),
					@eventcode varchar(6),
					@radius decimal(7,2) OUTPUT,
					@radiusunits varchar(6) OUTPUT,
					@timeout int OUTPUT

AS
BEGIN

-- Specific company, Specific event check
-- Most restrictive lookup
select 		@radius = gfc_auto_radius,
		@radiusunits =	gfc_auto_radiusunits,
		@timeout = gfc_auto_timeout
FROM		geofence_defaults
WHERE		gfc_auto_cmp_id = @cmp_id AND
		gfc_auto_evt = @eventcode AND
		gfc_auto_type = 'ARVING'

If @@rowcount > 0 
	Return 1

-- Specific Company, ALL event check
-- Wouldn't get here unless no record found at company/event level
-- Specific company, Specific event check
-- Most restrictive lookup
select 		@radius = gfc_auto_radius,
		@radiusunits =	gfc_auto_radiusunits,
		@timeout = gfc_auto_timeout
FROM		geofence_defaults
WHERE		gfc_auto_cmp_id = @cmp_id AND
		gfc_auto_evt = 'ALL' AND
		gfc_auto_type = 'ARVING'

If @@rowcount > 0 
	Return 1


-- UNKNOWN company, Specific event check
-- Wouldn't get here unless no record found at company/ALL level
select 		@radius = gfc_auto_radius,
		@radiusunits =	gfc_auto_radiusunits,
		@timeout = gfc_auto_timeout
FROM		geofence_defaults
WHERE		gfc_auto_cmp_id = 'UNKNOWN' AND
		gfc_auto_evt = @eventcode AND
		gfc_auto_type = 'ARVING'

If @@rowcount > 0 
	Return 1


-- UNKNOWN company, ALL Event Check
-- Wouldn't get here unless no record found at UNKNOWN/Specific event level
select 		@radius = gfc_auto_radius,
		@radiusunits =	gfc_auto_radiusunits,
		@timeout = gfc_auto_timeout
FROM		geofence_defaults
WHERE		gfc_auto_cmp_id = 'UNKNOWN' AND
		gfc_auto_evt = 'ALL' AND
		gfc_auto_type = 'ARVING'

If @@rowcount > 0 
	Return 1


-- Would only return -1 if no records found at any level
Return -1
END
GO
GRANT EXECUTE ON  [dbo].[get_geofence_defaults_sp] TO [public]
GO

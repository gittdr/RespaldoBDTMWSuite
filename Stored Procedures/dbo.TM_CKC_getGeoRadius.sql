SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[TM_CKC_getGeoRadius](@stp_number int, @gfc_auto_type varchar(6), @radius decimal(7,2) out, @outFlags int out)

AS

SET NOCOUNT ON

BEGIN

/*
pass:
	@stp_number = stop id
	@gfc_auto_type = geofence type: 'ARVING'|'ARVED'|'DEPED'
return:
	@radius = geofence radius in terms of miles,
	@outFlags: bit flags 
		1 = Hold depart event until outside depart fence. ('DEPED' type only)
		2 = Create message to read only, do not update trip. 
		4, 8, 16, ... = undefined

proc retrives 'comp id', 'stop event' and 'stop actualized flag' 
and tries to get 'geofence radius' as follows:
	cmp, event, type
	cmp, event, UNKNOWN
	cmp, ANY, type
	cmp, ANY, UNKNOWN
	UNKNOWN, event, type
	UNKNOWN, event, UNKNOWN
	UNKNOWN, ALL, type
	UNKNOWN, ALL, UNKNOWN
*/

DECLARE 
	@cmp_id varchar(25), --PTS 61189 INCREASE LENGTH TO 25
	@stp_event varchar(6),
	@stp_status varchar(6),
	@type char(5),		-- Estimated OPN ARVED | Actualized DNE DEPED
	@radiusunits varchar(6),
	@emailLateCc varchar(1024)

SELECT @outFlags = 0

-- Assumption: IF stop has been actualized - truck is departing, IF not - arriving
SELECT @cmp_id = cmp_id, @stp_event = stp_event, @stp_status = stp_status 
FROM stops (NOLOCK)
WHERE stp_number = @stp_number

IF isnull(@gfc_auto_type,'') = '' 
	SELECT @type = replace(replace(@stp_status,'OPN','ARVED'),'DNE','DEPED') 
else
	SELECT @type = @gfc_auto_type
		
IF @cmp_id is null 
BEGIN
	SELECT @radius = 0
	return
END	

--1 cmp, event, type
SELECT @radius = gfc_auto_radius, @radiusunits = gfc_auto_radiusunits, @emailLateCc = gfc_auto_email_late_cc 
FROM geofence_defaults (NOLOCK) 
WHERE gfc_auto_cmp_id = @cmp_id and gfc_auto_evt = @stp_event and gfc_auto_type = @type 

IF @@rowcount=0
BEGIN
	--2 cmp, event, UNKNOWN
	SELECT @radius = gfc_auto_radius, @radiusunits = gfc_auto_radiusunits, @emailLateCc = gfc_auto_email_late_cc 
	FROM geofence_defaults (NOLOCK)
	WHERE gfc_auto_cmp_id = @cmp_id and gfc_auto_evt = @stp_event and gfc_auto_type = 'UNK'
	
	IF @@rowcount=0
	BEGIN
		--3 cmp, ANY, type
		SELECT @radius = gfc_auto_radius, @radiusunits = gfc_auto_radiusunits, @emailLateCc = gfc_auto_email_late_cc 
		FROM geofence_defaults (NOLOCK)
		WHERE gfc_auto_cmp_id = @cmp_id and gfc_auto_evt = 'ALL' and gfc_auto_type = @type
		IF @@rowcount=0
		BEGIN
			--4 cmp, ANY, UNKNOWN
			SELECT @radius = gfc_auto_radius, @radiusunits = gfc_auto_radiusunits, @emailLateCc = gfc_auto_email_late_cc 
			FROM geofence_defaults (NOLOCK)
			WHERE gfc_auto_cmp_id = @cmp_id and gfc_auto_evt = 'ALL' and gfc_auto_type = 'UNK'
			IF @@rowcount=0
			BEGIN
				--5 UNKNOWN, event, type
				SELECT @radius = gfc_auto_radius, @radiusunits = gfc_auto_radiusunits, @emailLateCc = gfc_auto_email_late_cc 
				FROM geofence_defaults (NOLOCK)
				WHERE gfc_auto_cmp_id = 'UNKNOWN' and gfc_auto_evt = @stp_event and gfc_auto_type = @type
				IF @@rowcount=0
				BEGIN
					--6 UNKNOWN, event, UNKNOWN
					SELECT @radius = gfc_auto_radius, @radiusunits = gfc_auto_radiusunits, @emailLateCc = gfc_auto_email_late_cc 
					FROM geofence_defaults (NOLOCK)
					WHERE gfc_auto_cmp_id = 'UNKNOWN' and gfc_auto_evt = @stp_event and gfc_auto_type = 'UNK'
					IF @@rowcount=0
					BEGIN
						--7 UNKNOWN, ALL, type
						SELECT @radius = gfc_auto_radius, @radiusunits = gfc_auto_radiusunits, @emailLateCc = gfc_auto_email_late_cc 
						FROM geofence_defaults (NOLOCK)
						WHERE gfc_auto_cmp_id = 'UNKNOWN' and gfc_auto_evt = 'ALL' and gfc_auto_type = @type
						IF @@rowcount=0
						BEGIN
							--8 UNKNOWN, ALL, UNKNOWN
							SELECT @radius = gfc_auto_radius, @radiusunits = gfc_auto_radiusunits, @emailLateCc = gfc_auto_email_late_cc 
							FROM geofence_defaults (NOLOCK)
							WHERE gfc_auto_cmp_id = 'UNKNOWN' and gfc_auto_evt = 'ALL' and gfc_auto_type = 'UNK'
							IF @@rowcount=0
							BEGIN
								SELECT @radius = -1
							END
						END
					END
				END
			END
		END
	END
END
SELECT @radius = 
	case @radiusunits
	when 'FT' then @radius / 5280
    when 'IN' then @radius / 63360
    when 'YD' then @radius / 1760
    when 'CM' then @radius * .000006214 --Note: CM will be removed as a choice. 10/3/03
	when 'MM' then @radius * .0006214 -- meters
	when 'KMS' then @radius * .6214 
    else -- 'MIL', 'UNK'
		@radius
	END

SELECT @emailLateCc = isnull(@emailLateCc,'')
IF @emailLateCc like '%[[]HoldDpt]%' or @emailLateCc like '%[[]HoldDpt:Y]%'
	IF @type = 'DEPED'	
		SELECT @outFlags = @outFlags | 1
IF @emailLateCc like '%[[]ReadOnly]%' or @emailLateCc like '%[[]ReadOnly:Y]%'
	SELECT @outFlags = @outFlags | 2
	
END

GO
GRANT EXECUTE ON  [dbo].[TM_CKC_getGeoRadius] TO [public]
GO

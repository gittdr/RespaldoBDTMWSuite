SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/**
 *
 * REVISION HISTORY:
 * 08/08/05 - MZ - Changed from using real table KillMe to temp table #KillMe
 * 12/10/08 - TA - Added all columns.
 * 01/22/14 - HA - pts74645 and changed temp #killme to var @KillMe
 *
**/

CREATE PROCEDURE [dbo].[tmail_Geocode_Information] 	@cmp_id varchar(25), -- PTS 61189 enhance cmp_id to 25 length
						@eventcode varchar(6),
						@Type varchar(6)

AS

SET NOCOUNT ON

--CREATE TABLE #KillMe 
declare @KillMe TABLE(gfc_auto_cmp_id varchar(25), -- PTS 61189 enhance cmp_id to 25 length
			gfc_auto_evt varchar(6), 
			gfc_auto_type varchar(6), 
			gfc_auto_radius decimal (7,2), 
			gfc_auto_radiusunits varchar(6),
			gfc_auto_radius_in_miles decimal (7,2), --pts 74645
			gfc_auto_timeout int, 
			gfc_auto_call_occur char(1), 
			gfc_auto_call_late char(1), 
			gfc_auto_formid_occur int, 
			gfc_auto_formid_late int, 
			gfc_auto_email_occur char(1), 
			gfc_auto_email_late char(1), 
			gfc_auto_email_occur_cc varchar(1024), 
			gfc_auto_email_late_cc varchar(1024),
			gfc_auto_replyformid_occur int,
			gfc_auto_replyformid_late int,    
			gfc_detention_warning_interval int,
			gfc_detention_warning_method int,
			gfc_driver_audible_prompt char(1),  
			gfc_driver_negative_prompt char(1),     
			gfc_auto_form_id_occur_2 int,    
			gfc_auto_form_id_occur_3 int,      
			gfc_auto_form_id_rule int
			)
-- Specific company, Specific event check
-- Most restrictive lookup
INSERT INTO @KillMe (gfc_auto_cmp_id, 
			gfc_auto_evt, 
			gfc_auto_type, 
			gfc_auto_radius, 
			gfc_auto_radiusunits, 
            gfc_auto_radius_in_miles , --pts 74645			
			gfc_auto_timeout, 
			gfc_auto_call_occur, 
			gfc_auto_call_late, 
			gfc_auto_formid_occur, 
			gfc_auto_formid_late, 
			gfc_auto_email_occur, 
			gfc_auto_email_late, 
			gfc_auto_email_occur_cc, 
			gfc_auto_email_late_cc,
			gfc_auto_replyformid_occur,
			gfc_auto_replyformid_late,
			gfc_detention_warning_interval,
			gfc_detention_warning_method,
			gfc_driver_audible_prompt,
			gfc_driver_negative_prompt,
			gfc_auto_form_id_occur_2,
			gfc_auto_form_id_occur_3,
			gfc_auto_form_id_rule          
			)
SELECT 	gfc_auto_cmp_id, 
	gfc_auto_evt, 
	gfc_auto_type, 
	gfc_auto_radius, 
	gfc_auto_radiusunits, 
	(select Case
	 when gfc_auto_radiusunits = 'MIL' then gfc_auto_radius  
	 when gfc_auto_radiusunits = 'FT' then gfc_auto_radius /5280 
	 when gfc_auto_radiusunits = 'MM' then gfc_auto_radius /1609.34  
	 when gfc_auto_radiusunits = 'YD' then gfc_auto_radius /1760  
	 when gfc_auto_radiusunits = 'KMS' then gfc_auto_radius /1.60934 
	 ELSE 0 END) gfc_auto_radius_in_miles
	, --pts 74645
	gfc_auto_timeout, 
	gfc_auto_call_occur, 
	gfc_auto_call_late, 
	gfc_auto_formid_occur, 
	gfc_auto_formid_late, 
	gfc_auto_email_occur, 
	gfc_auto_email_late, 
	gfc_auto_email_occur_cc, 
	gfc_auto_email_late_cc,
	gfc_auto_replyformid_occur,
	gfc_auto_replyformid_late,
	gfc_detention_warning_interval,
	gfc_detention_warning_method,
	gfc_driver_audible_prompt,
	gfc_driver_negative_prompt,
	gfc_auto_form_id_occur_2,
	gfc_auto_form_id_occur_3,
	gfc_auto_form_id_rule
FROM geofence_defaults
WHERE	gfc_auto_cmp_id = @cmp_id AND
	gfc_auto_evt = @eventcode AND
	gfc_auto_type = @Type

If (SELECT COUNT(*) FROM @KillMe) > 0 
  BEGIN
	SELECT 	gfc_auto_cmp_id, 
		gfc_auto_evt, 
		gfc_auto_type, 
		gfc_auto_radius, 
		gfc_auto_radiusunits, 
		gfc_auto_radius_in_miles, --pts 74645
		gfc_auto_timeout, 
		gfc_auto_call_occur, 
		gfc_auto_call_late, 
		gfc_auto_formid_occur, 
		gfc_auto_formid_late, 
		gfc_auto_email_occur, 
		gfc_auto_email_late, 
		gfc_auto_email_occur_cc, 
		gfc_auto_email_late_cc,
		gfc_auto_replyformid_occur,
		gfc_auto_replyformid_late,
		gfc_detention_warning_interval,
		gfc_detention_warning_method,
		gfc_driver_audible_prompt,
		gfc_driver_negative_prompt,
		gfc_auto_form_id_occur_2,
		gfc_auto_form_id_occur_3,
		gfc_auto_form_id_rule,
			gfc_auto_radius_in_miles		
	FROM @KillMe

	RETURN
  END

-- Specific Company, ALL event check
-- Wouldn't get here unless no record found at company/event level
-- Specific company, Specific event check
-- Most restrictive lookup
INSERT INTO @KillMe (gfc_auto_cmp_id, 
			gfc_auto_evt, 
			gfc_auto_type, 
			gfc_auto_radius, 
			gfc_auto_radiusunits, 
			gfc_auto_radius_in_miles, --pts 74645
			gfc_auto_timeout, 
			gfc_auto_call_occur, 
			gfc_auto_call_late, 
			gfc_auto_formid_occur, 
			gfc_auto_formid_late, 
			gfc_auto_email_occur, 
			gfc_auto_email_late, 
			gfc_auto_email_occur_cc, 
			gfc_auto_email_late_cc,
			gfc_auto_replyformid_occur,
			gfc_auto_replyformid_late,
			gfc_detention_warning_interval,
			gfc_detention_warning_method,
			gfc_driver_audible_prompt,
			gfc_driver_negative_prompt,
			gfc_auto_form_id_occur_2,
			gfc_auto_form_id_occur_3,
			gfc_auto_form_id_rule
			)
select 	gfc_auto_cmp_id, 
	gfc_auto_evt, 
	gfc_auto_type, 
	gfc_auto_radius, 
	gfc_auto_radiusunits, 
	(select Case
	 when gfc_auto_radiusunits = 'MIL' then gfc_auto_radius  
	 when gfc_auto_radiusunits = 'FT' then gfc_auto_radius /5280 
	 when gfc_auto_radiusunits = 'MM' then gfc_auto_radius /1609.34  
	 when gfc_auto_radiusunits = 'YD' then gfc_auto_radius /1760  
	 when gfc_auto_radiusunits = 'KMS' then gfc_auto_radius /1.60934 
	 ELSE 0 END) gfc_auto_radius_in_miles
	, --pts 74645
	gfc_auto_timeout, 
	gfc_auto_call_occur, 
	gfc_auto_call_late, 
	gfc_auto_formid_occur, 
	gfc_auto_formid_late, 
	gfc_auto_email_occur, 
	gfc_auto_email_late, 
	gfc_auto_email_occur_cc, 
	gfc_auto_email_late_cc,
	gfc_auto_replyformid_occur,
	gfc_auto_replyformid_late,
	gfc_detention_warning_interval,
	gfc_detention_warning_method,
	gfc_driver_audible_prompt,
	gfc_driver_negative_prompt,
	gfc_auto_form_id_occur_2,
	gfc_auto_form_id_occur_3,
	gfc_auto_form_id_rule
FROM geofence_defaults (NOLOCK)
WHERE	gfc_auto_cmp_id = @cmp_id AND
	gfc_auto_evt = 'ALL' AND
	gfc_auto_type = @Type

If (SELECT COUNT(*) FROM @KillMe) > 0 
  BEGIN
	select 	gfc_auto_cmp_id, 
		gfc_auto_evt, 
		gfc_auto_type, 
		gfc_auto_radius, 
		gfc_auto_radiusunits, 
		gfc_auto_radius_in_miles, --pts 74645
		gfc_auto_timeout, 
		gfc_auto_call_occur, 
		gfc_auto_call_late, 
		gfc_auto_formid_occur, 
		gfc_auto_formid_late, 
		gfc_auto_email_occur, 
		gfc_auto_email_late, 
		gfc_auto_email_occur_cc, 
		gfc_auto_email_late_cc,
		gfc_auto_replyformid_occur,
		gfc_auto_replyformid_late,
		gfc_detention_warning_interval,
		gfc_detention_warning_method,
		gfc_driver_audible_prompt,
		gfc_driver_negative_prompt,
		gfc_auto_form_id_occur_2,
		gfc_auto_form_id_occur_3,
		gfc_auto_form_id_rule
	FROM @KillMe

	RETURN
  END

-- UNKNOWN company, Specific event check
-- Wouldn't get here unless no record found at company/ALL level
INSERT INTO @KillMe (gfc_auto_cmp_id, 
			gfc_auto_evt, 
			gfc_auto_type, 
			gfc_auto_radius, 
			gfc_auto_radiusunits, 
			gfc_auto_radius_in_miles, --pts 74645
			gfc_auto_timeout, 
			gfc_auto_call_occur, 
			gfc_auto_call_late, 
			gfc_auto_formid_occur, 
			gfc_auto_formid_late, 
			gfc_auto_email_occur, 
			gfc_auto_email_late, 
			gfc_auto_email_occur_cc, 
			gfc_auto_email_late_cc,
			gfc_auto_replyformid_occur,
			gfc_auto_replyformid_late,
			gfc_detention_warning_interval,
			gfc_detention_warning_method,
			gfc_driver_audible_prompt,
			gfc_driver_negative_prompt,
			gfc_auto_form_id_occur_2,
			gfc_auto_form_id_occur_3,
			gfc_auto_form_id_rule
			)
select 	gfc_auto_cmp_id, 
	gfc_auto_evt, 
	gfc_auto_type, 
	gfc_auto_radius, 
	gfc_auto_radiusunits, 
	(select Case
	 when gfc_auto_radiusunits = 'MIL' then gfc_auto_radius  
	 when gfc_auto_radiusunits = 'FT' then gfc_auto_radius /5280 
	 when gfc_auto_radiusunits = 'MM' then gfc_auto_radius /1609.34  
	 when gfc_auto_radiusunits = 'YD' then gfc_auto_radius /1760  
	 when gfc_auto_radiusunits = 'KMS' then gfc_auto_radius /1.60934 
	 ELSE 0 END) gfc_auto_radius_in_miles
	, --pts 74645
	gfc_auto_timeout, 
	gfc_auto_call_occur, 
	gfc_auto_call_late, 
	gfc_auto_formid_occur, 
	gfc_auto_formid_late, 
	gfc_auto_email_occur, 
	gfc_auto_email_late, 
	gfc_auto_email_occur_cc, 
	gfc_auto_email_late_cc,
	gfc_auto_replyformid_occur,
	gfc_auto_replyformid_late,
	gfc_detention_warning_interval,
	gfc_detention_warning_method,
	gfc_driver_audible_prompt,
	gfc_driver_negative_prompt,
	gfc_auto_form_id_occur_2,
	gfc_auto_form_id_occur_3,
	gfc_auto_form_id_rule
FROM geofence_defaults (NOLOCK)
WHERE	gfc_auto_cmp_id = 'UNKNOWN' AND
	gfc_auto_evt = @eventcode AND
	gfc_auto_type = @Type

If (SELECT COUNT(*) FROM @KillMe) > 0 
  BEGIN
	select 	gfc_auto_cmp_id, 
		gfc_auto_evt, 
		gfc_auto_type, 
		gfc_auto_radius, 
		gfc_auto_radiusunits, 
		gfc_auto_radius_in_miles, --pts 74645
		gfc_auto_timeout, 
		gfc_auto_call_occur, 
		gfc_auto_call_late, 
		gfc_auto_formid_occur, 
		gfc_auto_formid_late, 
		gfc_auto_email_occur, 
		gfc_auto_email_late, 
		gfc_auto_email_occur_cc, 
		gfc_auto_email_late_cc,
		gfc_auto_replyformid_occur,
		gfc_auto_replyformid_late,
		gfc_detention_warning_interval,
		gfc_detention_warning_method,
		gfc_driver_audible_prompt,
		gfc_driver_negative_prompt,
		gfc_auto_form_id_occur_2,
		gfc_auto_form_id_occur_3,
		gfc_auto_form_id_rule
	FROM @KillMe

	RETURN
  END

-- UNKNOWN company, ALL Event Check
-- Wouldn't get here unless no record found at UNKNOWN/Specific event level
INSERT INTO @KillMe (gfc_auto_cmp_id, 
			gfc_auto_evt, 
			gfc_auto_type, 
			gfc_auto_radius, 
			gfc_auto_radiusunits, 
			gfc_auto_radius_in_miles, --pts 74645
			gfc_auto_timeout, 
			gfc_auto_call_occur, 
			gfc_auto_call_late, 
			gfc_auto_formid_occur, 
			gfc_auto_formid_late, 
			gfc_auto_email_occur, 
			gfc_auto_email_late, 
			gfc_auto_email_occur_cc, 
			gfc_auto_email_late_cc,
			gfc_auto_replyformid_occur,
			gfc_auto_replyformid_late,
			gfc_detention_warning_interval,
			gfc_detention_warning_method,
			gfc_driver_audible_prompt,
			gfc_driver_negative_prompt,
			gfc_auto_form_id_occur_2,
			gfc_auto_form_id_occur_3,
			gfc_auto_form_id_rule
			)
select 	gfc_auto_cmp_id, 
	gfc_auto_evt, 
	gfc_auto_type, 
	gfc_auto_radius, 
	gfc_auto_radiusunits, 
	(select Case
	 when gfc_auto_radiusunits = 'MIL' then gfc_auto_radius  
	 when gfc_auto_radiusunits = 'FT' then gfc_auto_radius /5280 
	 when gfc_auto_radiusunits = 'MM' then gfc_auto_radius /1609.34  
	 when gfc_auto_radiusunits = 'YD' then gfc_auto_radius /1760  
	 when gfc_auto_radiusunits = 'KMS' then gfc_auto_radius /1.60934 
	 ELSE 0 END) gfc_auto_radius_in_miles
	, --pts 74645
	gfc_auto_timeout, 
	gfc_auto_call_occur, 
	gfc_auto_call_late, 
	gfc_auto_formid_occur, 
	gfc_auto_formid_late, 
	gfc_auto_email_occur, 
	gfc_auto_email_late, 
	gfc_auto_email_occur_cc, 
	gfc_auto_email_late_cc,
	gfc_auto_replyformid_occur,
	gfc_auto_replyformid_late,
	gfc_detention_warning_interval,
	gfc_detention_warning_method,
	gfc_driver_audible_prompt,
	gfc_driver_negative_prompt,
	gfc_auto_form_id_occur_2,
	gfc_auto_form_id_occur_3,
	gfc_auto_form_id_rule
FROM geofence_defaults (NOLOCK)
WHERE	gfc_auto_cmp_id = 'UNKNOWN' AND
	gfc_auto_evt = 'ALL' AND
	gfc_auto_type = @Type

select 	gfc_auto_cmp_id, 
	gfc_auto_evt, 
	gfc_auto_type, 
	gfc_auto_radius, 
	gfc_auto_radiusunits, 
	gfc_auto_radius_in_miles, --pts 74645
	gfc_auto_timeout, 
	gfc_auto_call_occur, 
	gfc_auto_call_late, 
	gfc_auto_formid_occur, 
	gfc_auto_formid_late, 
	gfc_auto_email_occur, 
	gfc_auto_email_late, 
	gfc_auto_email_occur_cc, 
	gfc_auto_email_late_cc,
	gfc_auto_replyformid_occur,
	gfc_auto_replyformid_late,
	gfc_detention_warning_interval,
	gfc_detention_warning_method,
	gfc_driver_audible_prompt,
	gfc_driver_negative_prompt,
	gfc_auto_form_id_occur_2,
	gfc_auto_form_id_occur_3,
	gfc_auto_form_id_rule
FROM @KillMe
GO
GRANT EXECUTE ON  [dbo].[tmail_Geocode_Information] TO [public]
GO

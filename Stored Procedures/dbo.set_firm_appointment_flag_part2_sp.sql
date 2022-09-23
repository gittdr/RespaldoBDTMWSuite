SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE	procedure [dbo].[set_firm_appointment_flag_part2_sp]  @cmp_id varchar(8),  @brn_id varchar(12),  @first_drop char(1),  @rtn_value char(1) output

AS 


IF @cmp_id is null
	Begin   
		SET @cmp_id = ''
	End

IF @brn_id is null
	Begin   
		SET @brn_id = ''
	End
IF @first_drop is null
	Begin
		SET @first_drop = ''
	End

declare @cmp_firm_appt_value varchar(15)
DECLARE @brn_firm_appt_value VARCHAR(15)

set @cmp_firm_appt_value =	(select cmp_firm_appt_value from company where cmp_id = @cmp_id ) 
set @brn_firm_appt_value =	( select brn_firm_appt_value from branch  where brn_id = @brn_id ) 


SET @rtn_value = null 

-- per Todd Krall 7-18-2008 if company firm appt value is null make it check branch.
--IF @cmp_firm_appt_value is null
--	BEGIN
--		SET @rtn_value = null 
--	END 

-- per Todd Krall 7-18-2008 if company firm appt value is null make it check branch.
IF @cmp_firm_appt_value is null
	BEGIN
		SET @cmp_firm_appt_value = 'CHECK_BRANCH'
	END 


IF @cmp_firm_appt_value = 'NEVER'
	BEGIN
		SET @rtn_value = null 
	END 

IF @cmp_firm_appt_value = 'ALL_UNLOADS'
	BEGIN
		SET @rtn_value = 'Y'
	END 

IF  @cmp_firm_appt_value = 'FIRST_UNLOAD'  AND  @first_drop = 'Y'
	BEGIN
		SET @rtn_value = 'Y'
	END 



IF @cmp_firm_appt_value = 'CHECK_BRANCH'
	BEGIN	

		-- per Todd Krall 7-18-2008 if branch firm appt value is null make it never.
--		IF @brn_firm_appt_value is null		
--			BEGIN
--				SET @rtn_value = null 
--			END 

		-- per Todd Krall 7-18-2008 if branch firm appt value is null make it never.
		IF @brn_firm_appt_value is null		
			BEGIN
				SET @brn_firm_appt_value = 'NEVER'
			END 

		IF @brn_firm_appt_value = 'NEVER'
			BEGIN
				SET @rtn_value = null 
			END 
			
		IF @brn_firm_appt_value = 'ALL_UNLOADS'
			BEGIN
		SET @rtn_value = 'Y'
			END 

		IF  @brn_firm_appt_value = 'FIRST_UNLOAD'  AND  @first_drop = 'Y'
			BEGIN
				SET @rtn_value = 'Y'
			END 

	END


select @rtn_value

RETURN 


GO
GRANT EXECUTE ON  [dbo].[set_firm_appointment_flag_part2_sp] TO [public]
GO

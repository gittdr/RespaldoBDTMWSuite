SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ud_manpower_1_fn] (@p_data varchar(255), @Header_or_Data varchar(2))	
returns varchar(255) 
AS 
begin 
  declare @return varchar(255) 
  
  SET @Header_or_Data = UPPER(@Header_or_Data)
	IF @Header_or_Data = 'HA' --Header For Stop
	BEGIN
		SET @return = 'City Time Zone' 
	END
	IF @Header_or_Data = 'HP' --Header For Stop
	BEGIN
		SET @return = 'Prior Time Zone' 
	END
	IF @Header_or_Data = 'HN' --Header For Stop
	BEGIN
		SET @return = 'Next Time Zone' 
	END		
	IF @Header_or_Data = 'MA' -- City 
    BEGIN
		Select @return = 	
			isnull(CASE cty_DSTApplies WHEN 'Y' 
			THEN 
				CASE isnull(label_extrastring1,'') WHEN ''
				THEN abbr+'/'+replace(abbr,'S','D')
				ELSE abbr+'/'+label_extrastring1
				END
			END,'UNKNOWN')
		from manpowerprofile mp
		left outer join city c
		on c.cty_code = mp.mpp_avl_city
		left outer join labelfile on code = cty_GMTDelta
		and labeldefinition = 'Timezone'
		where mp.mpp_id = @p_data
	END 
	IF @Header_or_Data = 'MP' -- City 
    BEGIN
		Select @return = 	
			isnull(CASE cty_DSTApplies WHEN 'Y' 
			THEN 
				CASE isnull(label_extrastring1,'') WHEN ''
				THEN abbr+'/'+replace(abbr,'S','D')
				ELSE abbr+'/'+label_extrastring1
				END
			END,'UNKNOWN')
		from manpowerprofile mp
		left outer join city c
		on c.cty_code = mp.mpp_prior_city
		left outer join labelfile on code = cty_GMTDelta
		and labeldefinition = 'Timezone'
		where mp.mpp_id = @p_data
	END 
	IF @Header_or_Data = 'MN' -- City 
    BEGIN
		Select @return = 	
			isnull(CASE cty_DSTApplies WHEN 'Y' 
			THEN 
				CASE isnull(label_extrastring1,'') WHEN ''
				THEN abbr+'/'+replace(abbr,'S','D')
				ELSE abbr+'/'+label_extrastring1
				END
			END,'UNKNOWN')
		from manpowerprofile mp
		left outer join city c
		on c.cty_code = mp.mpp_next_city
		left outer join labelfile on code = cty_GMTDelta
		and labeldefinition = 'Timezone'
		where mp.mpp_id = @p_data
	END 			

	
 
return @return 
END
GO
GRANT EXECUTE ON  [dbo].[ud_manpower_1_fn] TO [public]
GO

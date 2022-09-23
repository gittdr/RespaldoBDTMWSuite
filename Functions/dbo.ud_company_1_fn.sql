SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[ud_company_1_fn] (@p_data varchar(255), @Header_or_Data varchar(2))	
returns varchar(255) 
AS 
begin 
  declare @return varchar(255) 
  
  SET @Header_or_Data = UPPER(@Header_or_Data)
    --PTS 70513
	--IF @Header_or_Data = 'H' --Header For Stop
	IF @Header_or_Data in ('H', 'HO') --Header For Stop
	BEGIN
		SET @return = 'City Time Zone' 
	END
	--IF @Header_or_Data = 'CO' -- Company 
	IF @Header_or_Data in ('CO','C2') -- Company 
    BEGIN
		Select @return = 	
			isnull(CASE cty_DSTApplies WHEN 'Y' 
			THEN 
				CASE isnull(label_extrastring1,'') WHEN ''
				THEN abbr+'/'+replace(abbr,'S','D')
				ELSE abbr+'/'+label_extrastring1
				END
			ELSE
				CASE isnull(abbr,'') WHEN ''
				THEN 'UNKNOWN'
				ELSE abbr
				END
								
			END,'UNKNOWN')			
		from company co
		left outer join city c
		on c.cty_code = co.cmp_city
		left outer join labelfile on code = cty_GMTDelta
		and labeldefinition = 'Timezone'
		where co.cmp_id = @p_data
	END 

	
 
return @return 
END
GO
GRANT EXECUTE ON  [dbo].[ud_company_1_fn] TO [public]
GO

SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create function [dbo].[BuildLoadRequirementString](@mov int, @stp int) returns varchar(8000)
as
begin

if (@stp = 0 or @stp is null or @mov = 0 or @mov is null) return ''

DECLARE @lrq VARCHAR(8000)
  
SELECT @lrq = case when lrq_manditory = 'Y' then '*' + COALESCE(@lrq + ', ', '') + lrq_equip_type + ':' + lrq_type 
			  else COALESCE(@lrq + ', ', '') + lrq_equip_type + ':' + lrq_type end
FROM loadrequirement 
WHERE isnull(stp_number, @stp) = @stp and mov_number = @mov

return @lrq
end
GO
GRANT EXECUTE ON  [dbo].[BuildLoadRequirementString] TO [public]
GO

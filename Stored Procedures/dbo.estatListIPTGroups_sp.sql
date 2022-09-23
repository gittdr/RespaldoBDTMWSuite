SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatListIPTGroups_sp] 	
-- 31347 
-- Used to populate the GROUP dropdown list in estat's SHSETP app.
-- Return list of companies with id and name concatenated  
as 
SET NOCOUNT ON

select distinct cmp_othertype1 [group] from company
GO
GRANT EXECUTE ON  [dbo].[estatListIPTGroups_sp] TO [public]
GO

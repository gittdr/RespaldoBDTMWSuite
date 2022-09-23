SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatListIPTPlants_sp] 	@plantid varchar(8)
-- 31347 
-- Used to populate the PLANT dropdown list in estat's SHSETP app.
-- Return list of companies with id and name concatenated  
as 
SET NOCOUNT ON

-- If no parm supplied (typical case) return list of all companies in company table.
if @plantid = ''
select cmp_id + ' - ' + cmp_name combo, cmp_id  from company order by cmp_id
else -- otherwise parm is company id
-- return company name concatenated with id.
select cmp_id + ' - ' + cmp_name combo, cmp_id  from company where cmp_id = @plantid
GO
GRANT EXECUTE ON  [dbo].[estatListIPTPlants_sp] TO [public]
GO

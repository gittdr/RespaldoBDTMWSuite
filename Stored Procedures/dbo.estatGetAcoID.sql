SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetAcoID]  @login varchar(132)
-- Returns a list of aco company ids for a given esat user login
-- exec estatgetacoid 'admin'
AS
SET NOCOUNT ON
select cmp_id from ESTATACOLIST where login = @login order by cmp_id	
GO
GRANT EXECUTE ON  [dbo].[estatGetAcoID] TO [public]
GO

SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetAvailableTrailers_sp]
    @id varchar(8)  -- trailer id chars for  % search  
-- Returns a list of all AVL trailers whose ids begin with the @id string.
-- estatGetAvailableTrailers_sp ''
-- estatGetAvailableTrailers_sp '6'
AS
SET NOCOUNT ON
select trl_id from trailerprofile where trl_status = 'AVL' and trl_id like @id + '%'
order by trl_id
GO
GRANT EXECUTE ON  [dbo].[estatGetAvailableTrailers_sp] TO [public]
GO

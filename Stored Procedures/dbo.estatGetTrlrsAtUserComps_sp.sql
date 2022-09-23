SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[estatGetTrlrsAtUserComps_sp]
	@login Varchar(132), 
    @id varchar(8)  -- trailer id chars for  % search  
-- For a given estat user returns a list of all AVL tailers currenly 
-- located at the users profile companies, trailers whose ids begin with 
-- the @id string.
-- estatGetTrlrsAtUserComps_sp 'admin', ''
AS
SET NOCOUNT ON

--build list of profile companies
create table #temp2 (estatusercmpid varchar(8) not null) 
Insert into #temp2
select cmp_id from ESTATUSERCOMPANIES where login = @login 

select trl_id from trailerprofile where trl_avail_cmp_id in (select estatusercmpid from #temp2 ) 
	and trl_status = 'AVL' 
	and trl_id like @id + '%'
order by trl_id
GO
GRANT EXECUTE ON  [dbo].[estatGetTrlrsAtUserComps_sp] TO [public]
GO

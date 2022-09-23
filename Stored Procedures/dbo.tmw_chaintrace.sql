SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

create proc [dbo].[tmw_chaintrace] @spid smallint   as   
	declare @current_spid smallint
	declare @blocker_spid smallint   
	
	select @current_spid = @spid
   
	select @blocker_spid = blocked 
	from master.dbo.sysprocesses 
	where spid = @current_spid   

	while @blocker_spid != 0   
	begin
      		select @current_spid = @blocker_spid
		select @blocker_spid = blocked 
		from master.dbo.sysprocesses 
		where spid = @current_spid   
	end
	select 'process: '+convert( char, @current_spid )+ ' at root of lock chain' 
GO

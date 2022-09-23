SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[aggregate_reassign_sp]	(	
										@p_mov_number	int,
										@p_new_driver	varchar(8),
										@p_new_tractor	varchar(8),
										@p_new_trailer	varchar(13),
										@p_new_carrier	varchar(8)
										) 
AS

/**
 * 
 * NAME:
 * aggregate_reassign_sp
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:  This procedure will take a given move number and re-assign to new assets.  This is to be used for the Aggregate
 *               Re-Assignment process which should only be run against single leg non-crossdocked/consolidated trips
 *
 * RETURNS: 
 *
 * RESULT SETS: 
 *
 * PARAMETERS:
 * @p_mov_number	int				Mov number
 * @p_new_driver	varchar(8)		Driver ID to be reassigned to the trip
 * @p_new_tractor	varchar(8)		Tractor ID to be reassigned to the trip
 * @p_new_trailer	varchar(13)		Trailer ID to be reassigned to the trip
 * @p_new_carrier	varchar(8)		Carrier ID to be reassigned to the trip
 *
 *
 * REVISION HISTORY:
 * 02/06/2007 ? PTS36113 - Jason Bauwin ? Original Release
 *
 **/

declare @err int

begin transaction
update event   
   set skip_trigger = 1,  
	   evt_carrier = @p_new_carrier,   
	   evt_driver1 = @p_new_driver,   
	   evt_driver2 = 'UNKNOWN',   
	   evt_tractor = @p_new_tractor,   
	   evt_trailer1 = @p_new_trailer,   
	   evt_trailer2 = 'UNKNOWN'
 where evt_mov_number = @p_mov_number 

select @err = @@Error

if @err = 0
begin
	exec update_assetassignment @p_mov_number
	select @err = @@Error
end

if @err = 0 
begin
	exec update_move_light @p_mov_number
	select @err = @@Error
end

IF @err = 0 
	commit
ELSE 
	rollback
return @err

GO
GRANT EXECUTE ON  [dbo].[aggregate_reassign_sp] TO [public]
GO

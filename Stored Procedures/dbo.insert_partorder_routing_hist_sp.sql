SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[insert_partorder_routing_hist_sp] 
@por_group_identity	int, 
@por_identity		int,     
@poh_identity		int,     
@por_master_ordhdr	int,
@por_ordhdr		int,    	 
@por_origin		varchar(8),     
@por_begindate		datetime,  
@por_destination	varchar(8),
@por_enddate		datetime,
@por_updatedby		varchar(8),
@por_updatedon		datetime,
@por_route			varchar(15),
@por_trl_unload_dt	datetime,
@por_sequence	int

AS

/**
 * 
 * NAME:
 * partorder_routing_history
 *
 * TYPE:
 * StoredProcedure
 *
 * DESCRIPTION:
 * Inserts a record into the partorder_routing_history table using the parameters received
 *
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS:	
 * @por_group_identity		int		Identity column for history insert group	
 * @por_identity		int  		por_identity that is to be inserted
 * @poh_identity		int 		poh_identity that is to be inserted
 * @por_master_ordhdr		int		por_master_ordhdr that is to be inserted
 * @por_ordhdr			int		por_ordhdr that is to be inserted
 * @por_origin			varchar(8)	por_origin that is to be inserted
 * @por_begindate		datetime	por_begindate that is to be inserted
 * @por_destination		varchar(8)	por_destination that is to be inserted
 * @por_enddate			datetime	por_enddate that is to be inserted
 * @por_updatedby		varchar(8)	por_updatedby that is to be inserted
 * @por_updatedon		datetime	por_updatedon that is to be inserted
 *
 * REVISION HISTORY:
 * 9/12/2005.01 ? PTS29749 - Dan Hudec ? Created Procedure
 * 10/27/2008 PTS44706 - MRH
 *
 **/

Insert into partorder_routing_history(
por_group_identity, 
por_identity,     
poh_identity,     
por_master_ordhdr,
por_ordhdr,     
por_origin,     
por_begindate,  
por_destination,
por_enddate,
por_updatedby,
por_updatedon,
por_route,
por_trl_unload_dt,
por_sequence)

Values (
@por_group_identity, 
@por_identity,     
@poh_identity,     
@por_master_ordhdr,
@por_ordhdr,    	 
@por_origin,     
@por_begindate,  
@por_destination,
@por_enddate,
@por_updatedby,
@por_updatedon,
@por_route,
@por_trl_unload_dt,
@por_sequence)

GO
GRANT EXECUTE ON  [dbo].[insert_partorder_routing_hist_sp] TO [public]
GO

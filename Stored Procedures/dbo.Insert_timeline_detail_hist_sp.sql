SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[Insert_timeline_detail_hist_sp] 
@tld_group_identity	INT,
@tld_number 		INT,
@tlh_number 		INT,
@tld_sequence		INT,
@tld_master_ordnum	VARCHAR(12),
@tld_route		VARCHAR(15),
@tld_origin		VARCHAR(8),
@tld_arrive_orig	DATETIME,
@tld_arrive_orig_lead	INT,
@tld_depart_orig	DATETIME,
@tld_depart_orig_lead	INT,
@tld_dest		VARCHAR(8),
@tld_arrive_yard	DATETIME,
@tld_arrive_lead	INT,
@tld_arrive_dest 	DATETIME,
@tld_arrive_dest_lead 	INT,
@tld_updatedby		VARCHAR(20),
@tld_updatedon		DATETIME

AS

Insert into timeline_detail_history(
tld_group_identity,
tld_number,
tlh_number,
tld_sequence,
tld_master_ordnum,
tld_route,
tld_origin,
tld_arrive_orig,
tld_arrive_orig_lead,
tld_depart_orig,
tld_depart_orig_lead,
tld_dest,
tld_arrive_yard,
tld_arrive_lead,
tld_arrive_dest,
tld_arrive_dest_lead,
tld_updatedby,
tld_updatedon)

Values (
@tld_group_identity,
@tld_number,
@tlh_number,
@tld_sequence,
@tld_master_ordnum,
@tld_route,
@tld_origin,
@tld_arrive_orig,
@tld_arrive_orig_lead,
@tld_depart_orig,
@tld_depart_orig_lead,
@tld_dest,
@tld_arrive_yard,
@tld_arrive_lead,
@tld_arrive_dest,
@tld_arrive_dest_lead,
@tld_updatedby,
@tld_updatedon)


GO
GRANT EXECUTE ON  [dbo].[Insert_timeline_detail_hist_sp] TO [public]
GO

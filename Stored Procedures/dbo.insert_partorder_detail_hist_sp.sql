SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[insert_partorder_detail_hist_sp] 
@pod_group_identity	INT,
@pod_identity 		INT,
@poh_identity 		INT,
@pod_partnumber 	VARCHAR(20),
@pod_description 	VARCHAR(35),
@pod_uom 		VARCHAR(6),
@pod_originalcount 	INT,
@pod_originalcontainers INT,
@pod_countpercontainer 	INT,
@pod_adjustedcount 	INT,
@pod_adjustedcontainers INT,
@pod_pu_count 		INT,
@pod_pu_containers 	INT,
@pod_del_count 		INT,
@pod_del_containers 	INT,
@pod_cur_count 		INT,
@pod_cur_containers 	INT,
@pod_status 		VARCHAR(6),
@pod_updatedby 		VARCHAR(20),
@pod_updatedon 		DATETIME

AS

Insert into partorder_detail_history(
pod_group_identity,
pod_identity,
poh_identity,
pod_partnumber,
pod_description,
pod_uom,
pod_originalcount,
pod_originalcontainers,
pod_countpercontainer,
pod_adjustedcount,
pod_adjustedcontainers,
pod_pu_count,
pod_pu_containers,
pod_del_count,
pod_del_containers,
pod_cur_count,
pod_cur_containers,
pod_status,
pod_updatedby,
pod_updatedon)

Values (
@pod_group_identity,
@pod_identity,
@poh_identity,
@pod_partnumber,
@pod_description,
@pod_uom,
@pod_originalcount,
@pod_originalcontainers,
@pod_countpercontainer,
@pod_adjustedcount,
@pod_adjustedcontainers,
@pod_pu_count,
@pod_pu_containers,
@pod_del_count,
@pod_del_containers,
@pod_cur_count,
@pod_cur_containers,
@pod_status,
@pod_updatedby,
@pod_updatedon)

GO
GRANT EXECUTE ON  [dbo].[insert_partorder_detail_hist_sp] TO [public]
GO

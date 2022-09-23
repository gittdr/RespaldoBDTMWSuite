CREATE TABLE [dbo].[partorder_detail]
(
[pod_identity] [int] NOT NULL IDENTITY(1, 1),
[poh_identity] [int] NOT NULL,
[pod_partnumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[pod_description] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_uom] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_originalcount] [int] NOT NULL,
[pod_originalcontainers] [int] NULL,
[pod_countpercontainer] [int] NULL,
[pod_adjustedcount] [int] NULL,
[pod_adjustedcontainers] [int] NULL,
[pod_pu_count] [int] NULL,
[pod_pu_containers] [int] NULL,
[pod_del_count] [int] NULL,
[pod_del_containers] [int] NULL,
[pod_cur_count] [int] NOT NULL,
[pod_cur_containers] [int] NOT NULL,
[pod_status] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_updatedon] [datetime] NULL,
[pod_xdock] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_release] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_pending_count] [int] NULL,
[pod_skiptrigger] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_sourcefile] [varchar] (60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_pending_date] [datetime] NULL,
[pod_originalweight] [float] NULL,
[pod_pu_weight] [float] NULL,
[pod_cur_weight] [float] NULL,
[pod_adjustedweight] [float] NULL,
[pod_weightunit] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_originalUOM] [char] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[pod_modelyear] [int] NULL,
[pod_forecast1] [int] NULL,
[pod_forecast2] [int] NULL,
[pod_forecast3] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[ut_partorder_detail] ON [dbo].[partorder_detail] FOR UPDATE, DELETE
AS
SET NOCOUNT ON -- 06/25/2007 MDH PTS: 38085: Added 

/**
 * 
 * NAME:
 * ut_partorder_detail
 *
 * TYPE:
 * Trigger
 *
 * DESCRIPTION:
 * Inserts a record into the partorder_detail_history table from the 'deleted' table
 *
 * RETURNS: NONE
 *
 * RESULT SETS: NONE
 *
 * PARAMETERS: NONE
 *
 * REVISION HISTORY:
 * 9/12/2005.01 ? PTS29749 - Dan Hudec ? Created Trigger
 *
 * 5/12/08 MRH Status changes:
 * In the PO detail trigger; not CAMI specific:
 * 
 * pod_pu_count changes (it can only change from null to non-null, cannot be changed after is set to non-null value)
 * 	if detail status = 10, set to 50
 * 
 * If pod_cur_count change and details status = 60 set
 * 	55 PO Manager
 * 	58 All others
 * 
 * If header status = 10 and PO qty details are not null set to 50
 * 
 * If header status > 70 set to 70
 * 
 * 	In all cases header is set to lowest value of the details. Be sure to only update the header once. ** MRH END
 * 
 * 6/26/08 FMM Trigger fails with subquery problems when more than one partorder_detail record is updated
 **/

DECLARE @li_insert_count int,
	@li_delete_count int,
	@pod_group_identity int,
	@App_name varchar(255),
	@status integer,
	@poh_identity integer,
	@inserted_pod integer,
	@user VARCHAR(255)

IF (SELECT COUNT(0) FROM inserted where isnull(pod_skiptrigger,'N') = 'Y') > 0
begin
	UPDATE	partorder_detail
	SET 	partorder_detail.pod_skiptrigger = 'N'
	FROM	inserted i INNER JOIN deleted d
	ON	i.pod_identity = d.pod_identity
	WHERE	partorder_detail.pod_identity = i.pod_identity
	AND	isnull(partorder_detail.pod_skiptrigger, 'Y') <> 'N'
	AND 	isnull(i.pod_skiptrigger,'Y') = isnull(d.pod_skiptrigger,'Y')
	RETURN
end

--FMM 6/26/2008 new code to look through each inserted partorder_detail to prevent subquery problems
SELECT	@inserted_pod = 0

EXEC gettmwuser @user OUTPUT

WHILE 1=1
BEGIN
	SELECT @inserted_pod = MIN(poh_identity) FROM inserted WHERE poh_identity > @inserted_pod 
	IF @inserted_pod IS NULL BREAK

	IF UPDATE(pod_pu_count) AND (SELECT pod_pu_count FROM deleted WHERE pod_identity = @inserted_pod) IS NULL
	BEGIN
		UPDATE partorder_detail 
		SET pod_status = '50'
		FROM inserted i 
		WHERE i.pod_identity = partorder_detail.pod_identity
		  AND CAST(partorder_detail.pod_status AS INT) < 50
		  AND i.pod_pu_count > 0
		  AND partorder_detail.pod_identity = @inserted_pod  --FMM 6/26/2008
	END
	ELSE
	BEGIN
		IF UPDATE (pod_cur_count)
		BEGIN
			SELECT @App_name = APP_NAME()
			IF @App_name = 'DIS'
				UPDATE partorder_detail
				SET pod_status = '55'
				FROM inserted i
				WHERE i.pod_identity = partorder_detail.pod_identity
				AND CAST(partorder_detail.pod_status AS INT) <= 70
	--  			AND CAST(partorder_detail.pod_status AS INT) BETWEEN 60 AND 79
				AND partorder_detail.pod_identity = @inserted_pod  --FMM 6/26/2008
			ELSE
				UPDATE partorder_detail
				SET pod_status = '58'
				FROM inserted i
				WHERE i.pod_identity = partorder_detail.pod_identity
				AND CAST(partorder_detail.pod_status AS INT) <= 70
				AND partorder_detail.pod_identity = @inserted_pod  --FMM 6/26/2008
	
			UPDATE partorder_detail			-- If qty has changed and the status > 70 make it 70
			SET pod_status = '70'
			FROM inserted i
			WHERE i.pod_identity = partorder_detail.pod_identity
			AND CAST(partorder_detail.pod_status AS INT) > 70
			AND partorder_detail.pod_identity = @inserted_pod  --FMM 6/26/2008
		END
	END
END


--Update the partorder_header with the min value in the partorder details
	--FMM 6/26/2008: select @poh_identity = min(poh_identity) from partorder_detail where pod_identity = (select pod_identity from inserted)
	select @poh_identity = min(poh_identity) from partorder_detail where pod_identity in (select pod_identity from inserted)  --FMM 6/26/2008
	select @status = min (cast(isnull(pod_status, '10') as int)) from partorder_detail d where isnumeric (isnull(pod_status, '1')) = 1 and d.poh_identity = @poh_identity
	UPDATE PARTORDER_HEADER set poh_status = @status, poh_updatedby = @user, poh_updatedon = GETDATE()
		WHERE poh_identity = @poh_identity
		  AND poh_status <> @status -- DSK 7/29/08 PTS 43918

SELECT	@li_insert_count = count(1)
  FROM	inserted
SELECT	@li_delete_count = count(1)
  FROM	deleted

/* FMM 2/14/2008
SELECT 	@pod_group_identity = max(pod_group_identity) + 1
FROM	partorder_detail_history
*/
SELECT  @pod_group_identity = IDENT_CURRENT('partorder_detail_history') + 1

If IsNull(@pod_group_identity, '') = ''
 BEGIN
	Select @pod_group_identity = 1
 END

if @li_delete_count <> 0
 BEGIN

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

	SELECT	@pod_group_identity,
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
		pod_updatedon
	FROM 	Deleted
	WHERE	pod_skiptrigger = 'N'
	OR	@li_insert_count = 0

	IF @li_insert_count <> 0
		UPDATE	partorder_detail
		SET 	partorder_detail.pod_skiptrigger = 'N'
		FROM	inserted i INNER JOIN deleted d
		ON	i.pod_identity = d.pod_identity
		WHERE	partorder_detail.pod_identity = i.pod_identity
		AND	isnull(partorder_detail.pod_skiptrigger, 'Y') <> 'N'
		AND 	isnull(i.pod_skiptrigger,'Y') = isnull(d.pod_skiptrigger,'Y')
 END

RETURN

GO
CREATE NONCLUSTERED INDEX [idx_pod_id] ON [dbo].[partorder_detail] ([pod_identity]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_pod_poh_id] ON [dbo].[partorder_detail] ([poh_identity]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[partorder_detail] TO [public]
GO
GRANT INSERT ON  [dbo].[partorder_detail] TO [public]
GO
GRANT REFERENCES ON  [dbo].[partorder_detail] TO [public]
GO
GRANT SELECT ON  [dbo].[partorder_detail] TO [public]
GO
GRANT UPDATE ON  [dbo].[partorder_detail] TO [public]
GO

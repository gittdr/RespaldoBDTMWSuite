CREATE TABLE [dbo].[RowSecUserAssignments]
(
[rsua_id] [int] NOT NULL IDENTITY(1, 1),
[usr_userid] [char] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[rscv_id] [int] NOT NULL,
[rsua_idtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_RowSecUserAssignments_rsua_idtype] DEFAULT ('U'),
[rsua_wildcard] [bit] NOT NULL CONSTRAINT [DF_RowSecUserAssignments_rsua_wildcard] DEFAULT ((0)),
[rsc_id] [int] NULL,
[rst_id] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[i_RowSecUserAssignments] ON [dbo].[RowSecUserAssignments]
FOR INSERT
AS BEGIN

	SET NOCOUNT ON 

	--Denormalize for performance
	UPDATE	RowSecUserAssignments
	SET		rsc_id = rscv.rsc_id,
			rst_id = rsc.rst_id
	FROM	inserted rsua
			INNER JOIN RowSecColumnValues rscv on rsua.rscv_id = rscv.rscv_id
			INNER JOIN RowSecColumns rsc on rsc.rsc_id = rscv.rsc_id
	WHERE	RowSecUserAssignments.rsua_id = rsua.rsua_id
END

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iud_after_RowSecUserAssignments] ON [dbo].[RowSecUserAssignments]
AFTER INSERT,UPDATE,DELETE
AS BEGIN

	SET NOCOUNT ON 

	SELECT DISTINCT	rsc_id,
					rsua_idtype,
					usr_userid
	INTO	#UnknownsToCheck
	FROM	inserted
	WHERE	rsc_id IS NOT NULL
	
	UNION	
	
	SELECT DISTINCT rsc_id,
					rsua_idtype,
					usr_userid
	FROM	deleted
	WHERE	rsc_id IS NOT NULL

	--Set whether or not 'Unknown' entries are to be considered wildcards or not.
	SELECT	rsua.rsua_id,
			rsua_wildcard =	CASE (	SELECT	count(*)
									FROM	RowSecUserAssignments rsuainner
									WHERE	rsua.rsc_id = rsuainner.rsc_id 
											and rsua.rsua_idtype = rsuainner.rsua_idtype 
											and rsua.usr_userid = rsuainner.usr_userid
								)
								WHEN 1 THEN 1
								ELSE 0
							END
	INTO	#RowSecUserAssignmentsToUpdate
	FROM	RowSecUserAssignments rsua
			INNER JOIN RowSecColumnValues rscv on rsua.rscv_id = rscv.rscv_id
			INNER JOIN RowSecColumns rsc on rscv.rsc_id = rsc.rsc_id
			INNER JOIN #UnknownsToCheck uc on (uc.rsc_id = rsua.rsc_id and uc.rsua_idtype = rsua.rsua_idtype and uc.usr_userid = rsua.usr_userid)
	WHERE	rsc.rsc_unknown_value = rscv.rscv_value

	UPDATE	RowSecUserAssignments
	SET		rsua_wildcard =	rsua.rsua_wildcard
	FROM	#RowSecUserAssignmentsToUpdate rsua
	WHERE	RowSecUserAssignments.rsua_id = rsua.rsua_id
END

GO
ALTER TABLE [dbo].[RowSecUserAssignments] ADD CONSTRAINT [PK_RowSecUserAssignments_1] PRIMARY KEY CLUSTERED ([rsua_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_RowSecUserAssignments_rsua_idtype_usr_uderid_rscv_id] ON [dbo].[RowSecUserAssignments] ([rsua_idtype], [usr_userid], [rscv_id]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RowSecUserAssignments] ADD CONSTRAINT [FK_RowSecUserAssignments_RowSecColumnValues] FOREIGN KEY ([rscv_id]) REFERENCES [dbo].[RowSecColumnValues] ([rscv_id]) ON DELETE CASCADE
GO
GRANT DELETE ON  [dbo].[RowSecUserAssignments] TO [public]
GO
GRANT INSERT ON  [dbo].[RowSecUserAssignments] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RowSecUserAssignments] TO [public]
GO
GRANT SELECT ON  [dbo].[RowSecUserAssignments] TO [public]
GO
GRANT UPDATE ON  [dbo].[RowSecUserAssignments] TO [public]
GO

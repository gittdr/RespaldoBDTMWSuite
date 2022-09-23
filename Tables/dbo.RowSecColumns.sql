CREATE TABLE [dbo].[RowSecColumns]
(
[rsc_id] [int] NOT NULL IDENTITY(1, 1),
[rsc_system_locked] [bit] NOT NULL,
[rst_id] [int] NOT NULL,
[rsc_column_name] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[labeldefinition_values] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[labeldefinition_description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rsc_description] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rsc_selected] [bit] NOT NULL,
[rsc_sequence] [smallint] NOT NULL,
[rsc_unknown_value] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rsc_column_type] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rsc_description_proc] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE TRIGGER [dbo].[iut_RowSecColumns] ON [dbo].[RowSecColumns]
FOR INSERT, UPDATE
AS
	IF UPDATE(labeldefinition_description) BEGIN
		UPDATE	RowSecColumns
		SET		rsc_description = ISNULL	(	(	SELECT	CASE MAX(lbl_inner.userlabelname) 
																WHEN '' THEN NULL
																ELSE MAX(lbl_inner.userlabelname) 
															END
													FROM	labelfile lbl_inner 
													WHERE	lbl_inner.labeldefinition = lbl.labeldefinition
												),
												lbl.labeldefinition
											)
		FROM	labelfile lbl,
				inserted i_rsc
		WHERE	i_rsc.labeldefinition_description = lbl.labeldefinition
				AND RowSecColumns.rsc_id = i_rsc.rsc_id
	END
	
	IF UPDATE(labeldefinition_values) BEGIN
		--If row security has been applied previously with the updated column in use, this will fail due to foreign key constraints.
		
		--Delete existing values
		DELETE	RowSecColumnValues
		FROM	inserted i_rsc
		WHERE	RowSecColumnValues.rsc_id = i_rsc.rsc_id
		
		--Import values from label file
		INSERT	RowSecColumnValues	(
				rscv_Description,
				rsc_ID,
				rscv_Value
			)
			SELECT	lbl.name,
					rsc.rsc_ID,
					lbl.abbr
			FROM	labelfile lbl,
					RowSecColumns rsc
			WHERE	lbl.labeldefinition = rsc.labeldefinition_values
					AND NOT EXISTS	(	SELECT	*
										FROM	RowSecColumnValues rscv_inner
										WHERE	rscv_inner.rsc_ID = rsc.rsc_ID
												AND rscv_inner.rscv_Value = lbl.abbr
									)
	END

GO
ALTER TABLE [dbo].[RowSecColumns] ADD CONSTRAINT [PK_RowSecColumns] PRIMARY KEY CLUSTERED ([rsc_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_RowSecColumns_rst_ID_LevelName] ON [dbo].[RowSecColumns] ([rst_id], [rsc_column_name]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RowSecColumns] ADD CONSTRAINT [FK_RowSecColumns_RowSecTables] FOREIGN KEY ([rst_id]) REFERENCES [dbo].[RowSecTables] ([rst_id])
GO
GRANT DELETE ON  [dbo].[RowSecColumns] TO [public]
GO
GRANT INSERT ON  [dbo].[RowSecColumns] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RowSecColumns] TO [public]
GO
GRANT SELECT ON  [dbo].[RowSecColumns] TO [public]
GO
GRANT UPDATE ON  [dbo].[RowSecColumns] TO [public]
GO

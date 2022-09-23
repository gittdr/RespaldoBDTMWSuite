CREATE TABLE [dbo].[RowSecRowValues]
(
[rsrv_id] [int] NOT NULL IDENTITY(1, 1),
[rst_id] [int] NOT NULL,
[rscv_value1] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rscv_value2] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rscv_value3] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rscv_value4] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE  TRIGGER [dbo].[iut_RowSecRowValues] ON [dbo].[RowSecRowValues]
FOR INSERT, UPDATE
AS
BEGIN
	--PTS62831 exit if nothing actually changed
	IF	(SELECT count(*) FROM inserted) = 0
		AND	(SELECT count(*) FROM deleted) = 0 BEGIN
		RETURN
	END
	--END PTS62831 exit if nothing actually changed
	
	DELETE	RowSecRowColumnValues
	FROM	deleted dr
	WHERE	RowSecRowColumnValues.rsrv_id = dr.rsrv_id
	
	INSERT	RowSecColumnValues (
				rsc_id,
				rscv_value,
				rscv_description
			)
	SELECT DISTINCT	rsc.rsc_id,
			rsrv.rscv_value1,
			'(Undefined value)'
	FROM	inserted rsrv 
			INNER JOIN RowSecColumns rsc on rsrv.rst_id = rsc.rst_id
	WHERE	rsc.rsc_sequence = 1
			AND NOT EXISTS	(	SELECT	*
								FROM	RowSecColumnValues rscv 
								WHERE	rscv.rsc_id = rsc.rsc_id
										AND rscv.rscv_value = rsrv.rscv_value1
							)

				
	INSERT	RowSecRowColumnValues	(
			rsrv_id,
			rsc_sequence,
			rscv_id
	)
	SELECT	ir.rsrv_id,
			1,
			rscv.rscv_id
	FROM	inserted ir,
			RowSecColumnValues rscv
			INNER JOIN RowSecColumns rsc on (rscv.rsc_id = rsc.rsc_id)
	WHERE	rsc.rst_id = ir.rst_id
			AND rsc.rsc_sequence = 1
			AND rscv.rscv_value = ir.rscv_value1


	INSERT	RowSecColumnValues (
				rsc_id,
				rscv_value,
				rscv_description
			)
	SELECT DISTINCT rsc.rsc_id,
			rsrv.rscv_value2,
			'(Undefined value)'
	FROM	inserted rsrv 
			INNER JOIN RowSecColumns rsc on rsrv.rst_id = rsc.rst_id
	WHERE	rsc.rsc_sequence = 2
			AND NOT EXISTS	(	SELECT	*
								FROM	RowSecColumnValues rscv 
								WHERE	rscv.rsc_id = rsc.rsc_id
										AND rscv.rscv_value = rsrv.rscv_value2
							)

	INSERT	RowSecRowColumnValues	(
			rsrv_id,
			rsc_sequence,
			rscv_id
	)
	SELECT	ir.rsrv_id,
			2,
			rscv.rscv_id
	FROM	inserted ir,
			RowSecColumnValues rscv
			INNER JOIN RowSecColumns rsc on (rscv.rsc_id = rsc.rsc_id)
	WHERE	rsc.rst_id = ir.rst_id
			AND rsc.rsc_sequence = 2
			AND rscv.rscv_value = ir.rscv_value2


	INSERT	RowSecColumnValues (
				rsc_id,
				rscv_value,
				rscv_description
			)
	SELECT DISTINCT	rsc.rsc_id,
			rsrv.rscv_value3,
			'(Undefined value)'
	FROM	inserted rsrv 
			INNER JOIN RowSecColumns rsc on rsrv.rst_id = rsc.rst_id
	WHERE	rsc.rsc_sequence = 3
			AND NOT EXISTS	(	SELECT	*
								FROM	RowSecColumnValues rscv 
								WHERE	rscv.rsc_id = rsc.rsc_id
										AND rscv.rscv_value = rsrv.rscv_value3
							)

	INSERT	RowSecRowColumnValues	(
			rsrv_id,
			rsc_sequence,
			rscv_id
	)
	SELECT	ir.rsrv_id,
			3,
			rscv.rscv_id
	FROM	inserted ir,
			RowSecColumnValues rscv
			INNER JOIN RowSecColumns rsc on (rscv.rsc_id = rsc.rsc_id)
	WHERE	rsc.rst_id = ir.rst_id
			AND rsc.rsc_sequence = 3
			AND rscv.rscv_value = ir.rscv_value3

	INSERT	RowSecColumnValues (
				rsc_id,
				rscv_value,
				rscv_description
			)
	SELECT DISTINCT	rsc.rsc_id,
			rsrv.rscv_value4,
			'(Undefined value)'
	FROM	inserted rsrv 
			INNER JOIN RowSecColumns rsc on rsrv.rst_id = rsc.rst_id
	WHERE	rsc.rsc_sequence = 4
			AND NOT EXISTS	(	SELECT	*
								FROM	RowSecColumnValues rscv 
								WHERE	rscv.rsc_id = rsc.rsc_id
										AND rscv.rscv_value = rsrv.rscv_value4
							)

	INSERT	RowSecRowColumnValues	(
			rsrv_id,
			rsc_sequence,
			rscv_id
	)
	SELECT	ir.rsrv_id,
			4,
			rscv.rscv_id
	FROM	inserted ir,
			RowSecColumnValues rscv
			INNER JOIN RowSecColumns rsc on (rscv.rsc_id = rsc.rsc_id)
	WHERE	rsc.rst_id = ir.rst_id
			AND rsc.rsc_sequence = 4
			AND rscv.rscv_value = ir.rscv_value4

			
END 
 
GO
ALTER TABLE [dbo].[RowSecRowValues] ADD CONSTRAINT [PK_RowSecRowValues] PRIMARY KEY CLUSTERED ([rsrv_id]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_RowSecRowValues] ON [dbo].[RowSecRowValues] ([rst_id], [rscv_value1], [rscv_value2], [rscv_value3], [rscv_value4]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RowSecRowValues] ADD CONSTRAINT [FK_RowSecRowValues_RowSecTables] FOREIGN KEY ([rst_id]) REFERENCES [dbo].[RowSecTables] ([rst_id])
GO
GRANT DELETE ON  [dbo].[RowSecRowValues] TO [public]
GO
GRANT INSERT ON  [dbo].[RowSecRowValues] TO [public]
GO
GRANT REFERENCES ON  [dbo].[RowSecRowValues] TO [public]
GO
GRANT SELECT ON  [dbo].[RowSecRowValues] TO [public]
GO
GRANT UPDATE ON  [dbo].[RowSecRowValues] TO [public]
GO

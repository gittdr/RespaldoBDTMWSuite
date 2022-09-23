CREATE TABLE [dbo].[statemiles]
(
[sm_type] [int] NOT NULL,
[sm_origintype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sm_origin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sm_destinationtype] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sm_destination] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sm_sequence] [int] NOT NULL,
[sm_state] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[sm_freemiles] [decimal] (9, 1) NULL,
[sm_tollmiles] [decimal] (9, 1) NULL,
[sm_updatedby] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sm_updatedon] [datetime] NULL,
[timestamp] [timestamp] NULL,
[mt_Identity] [int] NULL,
[sm_statemiles_type1] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sm_statemiles_type2] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sm_miles] [float] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create TRIGGER [dbo].[it_statemiles]
ON [dbo].[statemiles]
FOR INSERT AS
/*
PTS 40260 Pauls recode 25276
*/

DECLARE @type1 VARCHAR(6), @type2 VARCHAR(6)

SELECT @type1 = gi_string1, @type2 = gi_string2
FROM generalinfo 
 WHERE gi_name = 'DefaultStateMilesTypes'

IF @type1 IS NOT NULL
	UPDATE statemiles
	SET sm_statemiles_type1 = @type1, sm_statemiles_type2 = @type2
	FROM inserted
	WHERE inserted.sm_type = statemiles.sm_type
	  AND	inserted.sm_origintype = statemiles.sm_origintype
	  AND inserted.sm_origin = statemiles.sm_origin
	  AND inserted.sm_destinationtype = statemiles.sm_destinationtype
	  AND inserted.sm_destination = statemiles.sm_destination
	  AND inserted.sm_sequence = statemiles.sm_sequence
	  AND inserted.sm_statemiles_type1 IS NULL
	  AND inserted.sm_statemiles_type2 IS NULL

GO
CREATE UNIQUE CLUSTERED INDEX [pk_statemiles] ON [dbo].[statemiles] ([mt_Identity], [sm_state]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [dk_statmiles] ON [dbo].[statemiles] ([sm_type], [sm_origintype], [sm_origin], [sm_destinationtype], [sm_destination], [sm_sequence]) ON [PRIMARY]
GO
GRANT DELETE ON  [dbo].[statemiles] TO [public]
GO
GRANT INSERT ON  [dbo].[statemiles] TO [public]
GO
GRANT REFERENCES ON  [dbo].[statemiles] TO [public]
GO
GRANT SELECT ON  [dbo].[statemiles] TO [public]
GO
GRANT UPDATE ON  [dbo].[statemiles] TO [public]
GO

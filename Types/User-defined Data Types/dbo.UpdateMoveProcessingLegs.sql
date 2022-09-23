CREATE TYPE [dbo].[UpdateMoveProcessingLegs] AS TABLE
(
[lgh_number] [int] NOT NULL,
[mov_number] [int] NULL,
[legcount] [int] NULL,
[sequence] [int] NULL,
[stp_number_start] [int] NULL,
[stp_number_end] [int] NULL,
PRIMARY KEY CLUSTERED ([lgh_number])
)
GO
GRANT EXECUTE ON TYPE:: [dbo].[UpdateMoveProcessingLegs] TO [public]
GO

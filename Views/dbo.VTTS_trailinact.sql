SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[VTTS_trailinact]
as

select

[Prior Region 1],[Available City],Trailer, DaysInactive,	Driver,
	[Destination Company],	[Available Date],	[Trailer Status] ,
	[TrlType3 Name], 	Misc4,	[Next Region 1],	[Available Company ID]


From VTTSTMW_inactivitybytrailer
where
([TrlType1 Name] in ('CAJA SECA','CAJA AMERICANA')) And (ActiveYN = 'y')
 And (DaysInactive > 6)



 And ([Trailer Status] <> 'SIN') And
([TrlType3 Name] not in( 'WM MTY','WM EXT','UNKNOWN','LIVERPOOL'))
GO

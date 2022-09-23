SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






create proc [dbo].[ida_LogOverride]
	@lgh_number int,
	@idTractorRec varchar(50),
	@idDriverRec varchar(50),
	@idCarrierRec varchar(50),
	@curValueRec decimal,
	@RecValueError varchar(200),
	@idTractorSel varchar(50),
	@idDriverSel varchar(50),
	@idCarrierSel varchar(50),
	@curValueSel decimal,
	@SelValueError varchar(200),
	@idReason varchar(8),
	@sComments text
as

insert ida_Override
(
	idUser,
	lgh_number,
	idTractorRecommendation,
	idDriverRecommendation,
	idCarrierRecommendation,
	curValueRecommendation,
	ValueErrorRecommendation,
	idTractorSelection,
	idDriverSelection,
	idCarrierSelection,
	curValueSelection,
	ValueErrorSelection,
	idReason,
	sComments,
	dtmCreated
)
values
(
	suser_sname(),
	@lgh_number,
	@idTractorRec,
	@idDriverRec,
	@idCarrierRec,
	@curValueRec,
	@RecValueError,
	@idTractorSel,
	@idDriverSel,
	@idCarrierSel,
	@curValueSel,
	@SelValueError,
	@idReason,
	@sComments,
	getdate()
)

select SCOPE_IDENTITY()





GO
GRANT EXECUTE ON  [dbo].[ida_LogOverride] TO [public]
GO

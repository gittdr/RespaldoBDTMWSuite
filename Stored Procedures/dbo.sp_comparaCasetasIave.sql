SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




---Sp para comparar casetas Creado el 30/04/2013

--execute sp_comparaCasetasIave 237610, 2
--drop procedure sp_comparaCasetasIave
CREATE PROCEDURE [dbo].[sp_comparaCasetasIave]
	-- Add the parameters for the stored procedure here
	@lgh_number int,
	@tipo int
AS
BEGIN
	Declare 
	@fechaIni datetime,
	@fechaFin datetime,
	@horaIni varchar(20),
	@horaFin varchar(20),
	@tractor varchar (5)

	--Se obtiene el inicio y fin del segmento para filtrar los cruces Iave
	select @fechaIni = lgh_startdate,@fechaFin =lgh_enddate,@tractor = lgh_tractor from legheader where lgh_number = @lgh_number
	--select @horaIni = (select convert(varchar(10), @fechaIni, 108))
	--select @horaFin = (select convert(varchar(10), @fechaFin, 108))
	
	--select @fechaIni
	--select @fechaFin
	
	if @tipo = 0
	begin
		select * from (
		select TAG,FECHA,HORA,EJES,idMapeo,IAVE..cruces.CASETA,COSTO,IAVE..casetasIave.caseta as casetaTMW,th_card_toll from IAVE..cruces left join IAVE..casetasIave  on  IAVE..casetasIave.caseta = IAVE..cruces.CASETA left join IAVE..mapeoCasetas on IAVE..casetasIave.id = IAVE..mapeoCasetas.idCasetaIAVE left join toll_history on toll_ident = idCasetaTMW where economico = @tractor and (fecha + hora) between @fechaIni and  @fechaFin and lgh_number = @lgh_number
		union
		select 'TMW' as TAG,'' as FECHA,'' as HORA, '' as EJES, toll_ident as idMapeo, '' as CASETA,0 as COSTO, tb_name,th_card_toll from toll_history left join tollbooth  on tb_ident = toll_ident  where lgh_number = @lgh_number and pyt_itemcode = 'CASIAV'  and toll_ident not in (
		select idCasetaTMW from IAVE..cruces left join IAVE..casetasIave  on  IAVE..casetasIave.caseta = IAVE..cruces.CASETA left join IAVE..mapeoCasetas on IAVE..casetasIave.id = IAVE..mapeoCasetas.idCasetaIAVE where economico = @tractor and (fecha + hora) between @fechaIni and  @fechaFin )
		union
		select 'IAVE',FECHA,HORA,EJES,idMapeo,IAVE..cruces.CASETA,COSTO,'','' from IAVE..cruces left join IAVE..casetasIave  on  IAVE..casetasIave.caseta = IAVE..cruces.CASETA left join IAVE..mapeoCasetas on IAVE..casetasIave.id = IAVE..mapeoCasetas.idCasetaIAVE where economico = @tractor and (fecha + hora) between @fechaIni and  @fechaFin and idCasetaTMW not in (
		select toll_ident from toll_history left join tollbooth  on tb_ident = toll_ident  where lgh_number = @lgh_number and pyt_itemcode = 'CASIAV')) as tb1 where TAG != 'TMW' and TAG != 'IAVE'
	end
	else if @tipo = 1
	begin
		select * from (
		select TAG,FECHA,HORA,EJES,idMapeo,IAVE..cruces.CASETA,COSTO,IAVE..casetasIave.caseta as casetaTMW,th_card_toll from IAVE..cruces left join IAVE..casetasIave  on  IAVE..casetasIave.caseta = IAVE..cruces.CASETA left join IAVE..mapeoCasetas on IAVE..casetasIave.id = IAVE..mapeoCasetas.idCasetaIAVE left join toll_history on toll_ident = idCasetaTMW where economico = @tractor and (fecha + hora) between @fechaIni and  @fechaFin and lgh_number = @lgh_number
		union
		select 'TMW' as TAG,'' as FECHA,'' as HORA, '' as EJES, toll_ident as idMapeo, '' as CASETA,0 as COSTO, tb_name,th_card_toll from toll_history left join tollbooth  on tb_ident = toll_ident  where lgh_number = @lgh_number and pyt_itemcode = 'CASIAV'  and toll_ident not in (
		select idCasetaTMW from IAVE..cruces left join IAVE..casetasIave  on  IAVE..casetasIave.caseta = IAVE..cruces.CASETA left join IAVE..mapeoCasetas on IAVE..casetasIave.id = IAVE..mapeoCasetas.idCasetaIAVE where economico = @tractor and (fecha + hora) between @fechaIni and  @fechaFin )
		union
		select 'IAVE',FECHA,HORA,EJES,idMapeo,IAVE..cruces.CASETA,COSTO,'','' from IAVE..cruces left join IAVE..casetasIave  on  IAVE..casetasIave.caseta = IAVE..cruces.CASETA left join IAVE..mapeoCasetas on IAVE..casetasIave.id = IAVE..mapeoCasetas.idCasetaIAVE where economico = @tractor and (fecha + hora) between @fechaIni and  @fechaFin and idCasetaTMW not in (
		select toll_ident from toll_history left join tollbooth  on tb_ident = toll_ident  where lgh_number = @lgh_number and pyt_itemcode = 'CASIAV')) as tb2 where TAG = 'TMW' 
	end
	else if @tipo = 2
	begin
		select * from (
		select TAG,FECHA,HORA,EJES,idMapeo,IAVE..cruces.CASETA,COSTO,IAVE..casetasIave.caseta as casetaTMW,th_card_toll from IAVE..cruces left join IAVE..casetasIave  on  IAVE..casetasIave.caseta = IAVE..cruces.CASETA left join IAVE..mapeoCasetas on IAVE..casetasIave.id = IAVE..mapeoCasetas.idCasetaIAVE left join toll_history on toll_ident = idCasetaTMW where economico = @tractor and (fecha + hora) between @fechaIni and  @fechaFin and lgh_number = @lgh_number
		union
		select 'TMW' as TAG,'' as FECHA,'' as HORA, '' as EJES, toll_ident as idMapeo, '' as CASETA,0 as COSTO, tb_name,th_card_toll from toll_history left join tollbooth  on tb_ident = toll_ident  where lgh_number = @lgh_number and pyt_itemcode = 'CASIAV'  and toll_ident not in (
		select idCasetaTMW from IAVE..cruces left join IAVE..casetasIave  on  IAVE..casetasIave.caseta = IAVE..cruces.CASETA left join IAVE..mapeoCasetas on IAVE..casetasIave.id = IAVE..mapeoCasetas.idCasetaIAVE where economico = @tractor and (fecha + hora) between @fechaIni and  @fechaFin )
		union
		select 'IAVE',FECHA,HORA,EJES,idMapeo,IAVE..cruces.CASETA,COSTO,'','' from IAVE..cruces left join IAVE..casetasIave  on  IAVE..casetasIave.caseta = IAVE..cruces.CASETA left join IAVE..mapeoCasetas on IAVE..casetasIave.id = IAVE..mapeoCasetas.idCasetaIAVE where economico = @tractor and (fecha + hora) between @fechaIni and  @fechaFin and idCasetaTMW not in (
		select toll_ident from toll_history left join tollbooth  on tb_ident = toll_ident  where lgh_number = @lgh_number and pyt_itemcode = 'CASIAV')) as tb3 where TAG = 'IAVE'
	end

	--select @horaIni
	--select @horaFin
	
END















GO

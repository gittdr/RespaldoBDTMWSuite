SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_Insert_Merc_Pisa_MX_JC](
@col1 varchar(100),
@col2 varchar(100),
@col3 varchar(100),
@col4 varchar(100),
@col5 varchar(100),
@col6 varchar(100),
@col7 varchar(100),
@col8 varchar(100),
@col9 varchar(100),
@col10 varchar(100),
@Av_cmd_code varchar(100),
@Av_cmd_description varchar(500),
@Av_countunit varchar(100),
@col14 varchar(100),
@Af_weight varchar(100),
@col16 varchar(100),
@col17 varchar(100),
@Af_count varchar(100),
@Av_weightunit varchar(100),
@col20 varchar(100),
@col21 varchar(100),
@col22 varchar(100),
@col23 varchar(100),
@col24 varchar(100),
@col25 varchar(100),
@col26 varchar(100),
@col27 varchar(100),
@col28 varchar(100),
@col29 varchar(100),
@col30 varchar(100),
@col31 varchar(100),
@col32 varchar(100),
@col33 varchar(100)
)
as
begin
		
		INSERT INTO TESTPISAUPLOAD(
		idenvio,
		rfcvendedora,
		razonsocialremitente,
		rfcoperador,
		razonsocialcontratante,
		rfccliente,
		razonsocialcliente,
		secuencia,
		fechahorallegada,
		fechahorasalida,
		claveprodservicio,
		descripcion,
		claveunidad,
		materialpeligroso,
		pesoenkg,
		valormercancia,
		moneda,
		numpiezas,
		unidadpeso,
		secuenciaorigen,
		municipio1,
		calle1,
		estado1,
		pais1,
		colonia1,
		codigopostal1,
		secuenciadestino,
		municipio2,
		calle2,
		estado2,
		pais2,
		colonia2,
		codigopostal2,
		origen
		)
		VALUES(
		@col1,
		@col2,
		@col3,
		@col4,
		@col5,
		@col6,
		@col7,
		@col8,
		@col9,
		@col10,
		@Av_cmd_code,
		@Av_cmd_description,
		@Av_countunit,
		@col14,
		@Af_weight,
		@col16,
		@col17,
		@Af_count,
		@Av_weightunit,
		@col20,
		@col21,
		@col22,
		@col23,
		@col24,
		@col25,
	    @col26,
		@col27,
		@col28,
		@col29,
		@col30,
		@col31,
		@col32,
		@col33,
		'MX'
		) 
end

GO
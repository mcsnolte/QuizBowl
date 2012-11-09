--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plperl; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plperl;


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

--
-- Name: citext; Type: SHELL TYPE; Schema: public; Owner: -
--

CREATE TYPE citext;


--
-- Name: citextin(cstring); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citextin(cstring) RETURNS citext
    LANGUAGE internal IMMUTABLE STRICT
    AS $$textin$$;


--
-- Name: citextout(citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citextout(citext) RETURNS cstring
    LANGUAGE internal IMMUTABLE STRICT
    AS $$textout$$;


--
-- Name: citextrecv(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citextrecv(internal) RETURNS citext
    LANGUAGE internal STABLE STRICT
    AS $$textrecv$$;


--
-- Name: citextsend(citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citextsend(citext) RETURNS bytea
    LANGUAGE internal STABLE STRICT
    AS $$textsend$$;


--
-- Name: citext; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE citext (
    INTERNALLENGTH = variable,
    INPUT = citextin,
    OUTPUT = citextout,
    RECEIVE = citextrecv,
    SEND = citextsend,
    CATEGORY = 'S',
    ALIGNMENT = int4,
    STORAGE = extended
);


--
-- Name: cube; Type: SHELL TYPE; Schema: public; Owner: -
--

CREATE TYPE cube;


--
-- Name: cube_in(cstring); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_in(cstring) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_in';


--
-- Name: cube_out(cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_out(cube) RETURNS cstring
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_out';


--
-- Name: cube; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE cube (
    INTERNALLENGTH = variable,
    INPUT = cube_in,
    OUTPUT = cube_out,
    ALIGNMENT = double,
    STORAGE = plain
);


--
-- Name: TYPE cube; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TYPE cube IS 'multi-dimensional cube ''(FLOAT-1, FLOAT-2, ..., FLOAT-N), (FLOAT-1, FLOAT-2, ..., FLOAT-N)''';


--
-- Name: cube_dim(cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_dim(cube) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_dim';


--
-- Name: cube_distance(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_distance(cube, cube) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_distance';


--
-- Name: cube_is_point(cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_is_point(cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_is_point';


--
-- Name: earth(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION earth() RETURNS double precision
    LANGUAGE sql IMMUTABLE
    AS $$SELECT '6378168'::float8$$;


--
-- Name: earth; Type: DOMAIN; Schema: public; Owner: -
--

CREATE DOMAIN earth AS cube
	CONSTRAINT not_3d CHECK ((cube_dim(VALUE) <= 3))
	CONSTRAINT not_point CHECK (cube_is_point(VALUE))
	CONSTRAINT on_surface CHECK ((abs(((cube_distance(VALUE, '(0)'::cube) / earth()) - (1)::double precision)) < 9.99999999999999955e-07::double precision));


--
-- Name: citext(character); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext(character) RETURNS citext
    LANGUAGE internal IMMUTABLE STRICT
    AS $$rtrim1$$;


--
-- Name: citext(boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext(boolean) RETURNS citext
    LANGUAGE internal IMMUTABLE STRICT
    AS $$booltext$$;


--
-- Name: citext(inet); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext(inet) RETURNS citext
    LANGUAGE internal IMMUTABLE STRICT
    AS $$network_show$$;


--
-- Name: citext_cmp(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_cmp(citext, citext) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_cmp';


--
-- Name: citext_eq(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_eq(citext, citext) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_eq';


--
-- Name: citext_ge(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_ge(citext, citext) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_ge';


--
-- Name: citext_gt(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_gt(citext, citext) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_gt';


--
-- Name: citext_hash(citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_hash(citext) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_hash';


--
-- Name: citext_larger(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_larger(citext, citext) RETURNS citext
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_larger';


--
-- Name: citext_le(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_le(citext, citext) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_le';


--
-- Name: citext_lt(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_lt(citext, citext) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_lt';


--
-- Name: citext_ne(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_ne(citext, citext) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_ne';


--
-- Name: citext_smaller(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION citext_smaller(citext, citext) RETURNS citext
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/citext', 'citext_smaller';


--
-- Name: cube(double precision[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(double precision[]) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_a_f8';


--
-- Name: cube(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_f8';


--
-- Name: cube(double precision[], double precision[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(double precision[], double precision[]) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_a_f8_f8';


--
-- Name: cube(double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(double precision, double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_f8_f8';


--
-- Name: cube(cube, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(cube, double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_c_f8';


--
-- Name: cube(cube, double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube(cube, double precision, double precision) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_c_f8_f8';


--
-- Name: cube_cmp(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_cmp(cube, cube) RETURNS integer
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_cmp';


--
-- Name: FUNCTION cube_cmp(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_cmp(cube, cube) IS 'btree comparison function';


--
-- Name: cube_contained(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_contained(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_contained';


--
-- Name: FUNCTION cube_contained(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_contained(cube, cube) IS 'contained in';


--
-- Name: cube_contains(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_contains(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_contains';


--
-- Name: FUNCTION cube_contains(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_contains(cube, cube) IS 'contains';


--
-- Name: cube_enlarge(cube, double precision, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_enlarge(cube, double precision, integer) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_enlarge';


--
-- Name: cube_eq(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_eq(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_eq';


--
-- Name: FUNCTION cube_eq(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_eq(cube, cube) IS 'same as';


--
-- Name: cube_ge(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_ge(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ge';


--
-- Name: FUNCTION cube_ge(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_ge(cube, cube) IS 'greater than or equal to';


--
-- Name: cube_gt(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_gt(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_gt';


--
-- Name: FUNCTION cube_gt(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_gt(cube, cube) IS 'greater than';


--
-- Name: cube_inter(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_inter(cube, cube) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_inter';


--
-- Name: cube_le(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_le(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_le';


--
-- Name: FUNCTION cube_le(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_le(cube, cube) IS 'lower than or equal to';


--
-- Name: cube_ll_coord(cube, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_ll_coord(cube, integer) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ll_coord';


--
-- Name: cube_lt(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_lt(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_lt';


--
-- Name: FUNCTION cube_lt(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_lt(cube, cube) IS 'lower than';


--
-- Name: cube_ne(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_ne(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ne';


--
-- Name: FUNCTION cube_ne(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_ne(cube, cube) IS 'different';


--
-- Name: cube_overlap(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_overlap(cube, cube) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_overlap';


--
-- Name: FUNCTION cube_overlap(cube, cube); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION cube_overlap(cube, cube) IS 'overlaps';


--
-- Name: cube_size(cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_size(cube) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_size';


--
-- Name: cube_subset(cube, integer[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_subset(cube, integer[]) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_subset';


--
-- Name: cube_union(cube, cube); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_union(cube, cube) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_union';


--
-- Name: cube_ur_coord(cube, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION cube_ur_coord(cube, integer) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'cube_ur_coord';


--
-- Name: earth_box(earth, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION earth_box(earth, double precision) RETURNS cube
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT cube_enlarge($1, gc_to_sec($2), 3)$_$;


--
-- Name: earth_distance(earth, earth); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION earth_distance(earth, earth) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT sec_to_gc(cube_distance($1, $2))$_$;


--
-- Name: g_cube_compress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_compress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_compress';


--
-- Name: g_cube_consistent(internal, cube, integer, oid, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_consistent(internal, cube, integer, oid, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_consistent';


--
-- Name: g_cube_decompress(internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_decompress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_decompress';


--
-- Name: g_cube_penalty(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_penalty(internal, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_penalty';


--
-- Name: g_cube_picksplit(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_picksplit(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_picksplit';


--
-- Name: g_cube_same(cube, cube, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_same(cube, cube, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_same';


--
-- Name: g_cube_union(internal, internal); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION g_cube_union(internal, internal) RETURNS cube
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/cube', 'g_cube_union';


--
-- Name: gc_to_sec(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gc_to_sec(double precision) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT CASE WHEN $1 < 0 THEN 0::float8 WHEN $1/earth() > pi() THEN 2*earth() ELSE 2*earth()*sin($1/(2*earth())) END$_$;


--
-- Name: geo_distance(point, point); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION geo_distance(point, point) RETURNS double precision
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/earthdistance', 'geo_distance';


--
-- Name: latitude(earth); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION latitude(earth) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT CASE WHEN cube_ll_coord($1, 3)/earth() < -1 THEN -90::float8 WHEN cube_ll_coord($1, 3)/earth() > 1 THEN 90::float8 ELSE degrees(asin(cube_ll_coord($1, 3)/earth())) END$_$;


--
-- Name: ll_to_earth(double precision, double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ll_to_earth(double precision, double precision) RETURNS earth
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT cube(cube(cube(earth()*cos(radians($1))*cos(radians($2))),earth()*cos(radians($1))*sin(radians($2))),earth()*sin(radians($1)))::earth$_$;


--
-- Name: longitude(earth); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION longitude(earth) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT degrees(atan2(cube_ll_coord($1, 2), cube_ll_coord($1, 1)))$_$;


--
-- Name: regexp_matches(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION regexp_matches(citext, citext) RETURNS text[]
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.regexp_matches( $1::pg_catalog.text, $2::pg_catalog.text, 'i' );
$_$;


--
-- Name: regexp_matches(citext, citext, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION regexp_matches(citext, citext, text) RETURNS text[]
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.regexp_matches( $1::pg_catalog.text, $2::pg_catalog.text, CASE WHEN pg_catalog.strpos($3, 'c') = 0 THEN  $3 || 'i' ELSE $3 END );
$_$;


--
-- Name: regexp_replace(citext, citext, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION regexp_replace(citext, citext, text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.regexp_replace( $1::pg_catalog.text, $2::pg_catalog.text, $3, 'i');
$_$;


--
-- Name: regexp_replace(citext, citext, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION regexp_replace(citext, citext, text, text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.regexp_replace( $1::pg_catalog.text, $2::pg_catalog.text, $3, CASE WHEN pg_catalog.strpos($4, 'c') = 0 THEN  $4 || 'i' ELSE $4 END);
$_$;


--
-- Name: regexp_split_to_array(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION regexp_split_to_array(citext, citext) RETURNS text[]
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.regexp_split_to_array( $1::pg_catalog.text, $2::pg_catalog.text, 'i' );
$_$;


--
-- Name: regexp_split_to_array(citext, citext, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION regexp_split_to_array(citext, citext, text) RETURNS text[]
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.regexp_split_to_array( $1::pg_catalog.text, $2::pg_catalog.text, CASE WHEN pg_catalog.strpos($3, 'c') = 0 THEN  $3 || 'i' ELSE $3 END );
$_$;


--
-- Name: regexp_split_to_table(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION regexp_split_to_table(citext, citext) RETURNS SETOF text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.regexp_split_to_table( $1::pg_catalog.text, $2::pg_catalog.text, 'i' );
$_$;


--
-- Name: regexp_split_to_table(citext, citext, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION regexp_split_to_table(citext, citext, text) RETURNS SETOF text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.regexp_split_to_table( $1::pg_catalog.text, $2::pg_catalog.text, CASE WHEN pg_catalog.strpos($3, 'c') = 0 THEN  $3 || 'i' ELSE $3 END );
$_$;


--
-- Name: replace(citext, citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION replace(citext, citext, citext) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.regexp_replace( $1::pg_catalog.text, pg_catalog.regexp_replace($2::pg_catalog.text, '([^a-zA-Z_0-9])', E'\\\\\\1', 'g'), $3::pg_catalog.text, 'gi' );
$_$;


--
-- Name: sec_to_gc(double precision); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION sec_to_gc(double precision) RETURNS double precision
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$SELECT CASE WHEN $1 < 0 THEN 0::float8 WHEN $1/(2*earth()) > 1 THEN pi()*earth() ELSE 2*earth()*asin($1/(2*earth())) END$_$;


--
-- Name: split_part(citext, citext, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION split_part(citext, citext, integer) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT (pg_catalog.regexp_split_to_array( $1::pg_catalog.text, pg_catalog.regexp_replace($2::pg_catalog.text, '([^a-zA-Z_0-9])', E'\\\\\\1', 'g'), 'i'))[$3];
$_$;


--
-- Name: strpos(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION strpos(citext, citext) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.strpos( pg_catalog.lower( $1::pg_catalog.text ), pg_catalog.lower( $2::pg_catalog.text ) );
$_$;


--
-- Name: texticlike(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION texticlike(citext, citext) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$texticlike$$;


--
-- Name: texticlike(citext, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION texticlike(citext, text) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$texticlike$$;


--
-- Name: texticnlike(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION texticnlike(citext, citext) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$texticnlike$$;


--
-- Name: texticnlike(citext, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION texticnlike(citext, text) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$texticnlike$$;


--
-- Name: texticregexeq(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION texticregexeq(citext, citext) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$texticregexeq$$;


--
-- Name: texticregexeq(citext, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION texticregexeq(citext, text) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$texticregexeq$$;


--
-- Name: texticregexne(citext, citext); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION texticregexne(citext, citext) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$texticregexne$$;


--
-- Name: texticregexne(citext, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION texticregexne(citext, text) RETURNS boolean
    LANGUAGE internal IMMUTABLE STRICT
    AS $$texticregexne$$;


--
-- Name: translate(citext, citext, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION translate(citext, citext, text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
    SELECT pg_catalog.translate( pg_catalog.translate( $1::pg_catalog.text, pg_catalog.lower($2::pg_catalog.text), $3), pg_catalog.upper($2::pg_catalog.text), $3);
$_$;


--
-- Name: uuid_generate_v1(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_generate_v1() RETURNS uuid
    LANGUAGE c STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v1';


--
-- Name: uuid_generate_v1mc(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_generate_v1mc() RETURNS uuid
    LANGUAGE c STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v1mc';


--
-- Name: uuid_generate_v3(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_generate_v3(namespace uuid, name text) RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v3';


--
-- Name: uuid_generate_v4(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_generate_v4() RETURNS uuid
    LANGUAGE c STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v4';


--
-- Name: uuid_generate_v5(uuid, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_generate_v5(namespace uuid, name text) RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_generate_v5';


--
-- Name: uuid_nil(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_nil() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_nil';


--
-- Name: uuid_ns_dns(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_ns_dns() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_dns';


--
-- Name: uuid_ns_oid(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_ns_oid() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_oid';


--
-- Name: uuid_ns_url(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_ns_url() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_url';


--
-- Name: uuid_ns_x500(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION uuid_ns_x500() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/uuid-ossp', 'uuid_ns_x500';


--
-- Name: >; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR > (
    PROCEDURE = citext_gt,
    LEFTARG = citext,
    RIGHTARG = citext,
    COMMUTATOR = <,
    NEGATOR = <=,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: max(citext); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE max(citext) (
    SFUNC = citext_larger,
    STYPE = citext,
    SORTOP = >
);


--
-- Name: <; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR < (
    PROCEDURE = citext_lt,
    LEFTARG = citext,
    RIGHTARG = citext,
    COMMUTATOR = >,
    NEGATOR = >=,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: min(citext); Type: AGGREGATE; Schema: public; Owner: -
--

CREATE AGGREGATE min(citext) (
    SFUNC = citext_smaller,
    STYPE = citext,
    SORTOP = <
);


--
-- Name: !~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR !~ (
    PROCEDURE = texticregexne,
    LEFTARG = citext,
    RIGHTARG = citext,
    NEGATOR = ~,
    RESTRICT = icregexnesel,
    JOIN = icregexnejoinsel
);


--
-- Name: !~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR !~ (
    PROCEDURE = texticregexne,
    LEFTARG = citext,
    RIGHTARG = text,
    NEGATOR = ~,
    RESTRICT = icregexnesel,
    JOIN = icregexnejoinsel
);


--
-- Name: !~*; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR !~* (
    PROCEDURE = texticregexne,
    LEFTARG = citext,
    RIGHTARG = citext,
    NEGATOR = ~*,
    RESTRICT = icregexnesel,
    JOIN = icregexnejoinsel
);


--
-- Name: !~*; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR !~* (
    PROCEDURE = texticregexne,
    LEFTARG = citext,
    RIGHTARG = text,
    NEGATOR = ~*,
    RESTRICT = icregexnesel,
    JOIN = icregexnejoinsel
);


--
-- Name: !~~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR !~~ (
    PROCEDURE = texticnlike,
    LEFTARG = citext,
    RIGHTARG = citext,
    NEGATOR = ~~,
    RESTRICT = icnlikesel,
    JOIN = icnlikejoinsel
);


--
-- Name: !~~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR !~~ (
    PROCEDURE = texticnlike,
    LEFTARG = citext,
    RIGHTARG = text,
    NEGATOR = ~~,
    RESTRICT = icnlikesel,
    JOIN = icnlikejoinsel
);


--
-- Name: !~~*; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR !~~* (
    PROCEDURE = texticnlike,
    LEFTARG = citext,
    RIGHTARG = citext,
    NEGATOR = ~~*,
    RESTRICT = icnlikesel,
    JOIN = icnlikejoinsel
);


--
-- Name: !~~*; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR !~~* (
    PROCEDURE = texticnlike,
    LEFTARG = citext,
    RIGHTARG = text,
    NEGATOR = ~~*,
    RESTRICT = icnlikesel,
    JOIN = icnlikejoinsel
);


--
-- Name: &&; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR && (
    PROCEDURE = cube_overlap,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = &&,
    RESTRICT = areasel,
    JOIN = areajoinsel
);


--
-- Name: <; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR < (
    PROCEDURE = cube_lt,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = >,
    NEGATOR = >=,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: <=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <= (
    PROCEDURE = cube_le,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = >=,
    NEGATOR = >,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: <=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <= (
    PROCEDURE = citext_le,
    LEFTARG = citext,
    RIGHTARG = citext,
    COMMUTATOR = >=,
    NEGATOR = >,
    RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);


--
-- Name: <>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <> (
    PROCEDURE = cube_ne,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <>,
    NEGATOR = =,
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: <>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <> (
    PROCEDURE = citext_ne,
    LEFTARG = citext,
    RIGHTARG = citext,
    COMMUTATOR = <>,
    NEGATOR = =,
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);


--
-- Name: <@; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <@ (
    PROCEDURE = cube_contained,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = @>,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: <@>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR <@> (
    PROCEDURE = geo_distance,
    LEFTARG = point,
    RIGHTARG = point,
    COMMUTATOR = <@>
);


--
-- Name: =; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR = (
    PROCEDURE = cube_eq,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = =,
    NEGATOR = <>,
    MERGES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: =; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR = (
    PROCEDURE = citext_eq,
    LEFTARG = citext,
    RIGHTARG = citext,
    COMMUTATOR = =,
    NEGATOR = <>,
    MERGES,
    HASHES,
    RESTRICT = eqsel,
    JOIN = eqjoinsel
);


--
-- Name: >; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR > (
    PROCEDURE = cube_gt,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <,
    NEGATOR = <=,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: >=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR >= (
    PROCEDURE = cube_ge,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <=,
    NEGATOR = <,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: >=; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR >= (
    PROCEDURE = citext_ge,
    LEFTARG = citext,
    RIGHTARG = citext,
    COMMUTATOR = <=,
    NEGATOR = <,
    RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);


--
-- Name: @; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @ (
    PROCEDURE = cube_contains,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = ~,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: @>; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR @> (
    PROCEDURE = cube_contains,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = <@,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: ~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~ (
    PROCEDURE = cube_contained,
    LEFTARG = cube,
    RIGHTARG = cube,
    COMMUTATOR = @,
    RESTRICT = contsel,
    JOIN = contjoinsel
);


--
-- Name: ~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~ (
    PROCEDURE = texticregexeq,
    LEFTARG = citext,
    RIGHTARG = citext,
    NEGATOR = !~,
    RESTRICT = icregexeqsel,
    JOIN = icregexeqjoinsel
);


--
-- Name: ~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~ (
    PROCEDURE = texticregexeq,
    LEFTARG = citext,
    RIGHTARG = text,
    NEGATOR = !~,
    RESTRICT = icregexeqsel,
    JOIN = icregexeqjoinsel
);


--
-- Name: ~*; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~* (
    PROCEDURE = texticregexeq,
    LEFTARG = citext,
    RIGHTARG = citext,
    NEGATOR = !~*,
    RESTRICT = icregexeqsel,
    JOIN = icregexeqjoinsel
);


--
-- Name: ~*; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~* (
    PROCEDURE = texticregexeq,
    LEFTARG = citext,
    RIGHTARG = text,
    NEGATOR = !~*,
    RESTRICT = icregexeqsel,
    JOIN = icregexeqjoinsel
);


--
-- Name: ~~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~~ (
    PROCEDURE = texticlike,
    LEFTARG = citext,
    RIGHTARG = citext,
    NEGATOR = !~~,
    RESTRICT = iclikesel,
    JOIN = iclikejoinsel
);


--
-- Name: ~~; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~~ (
    PROCEDURE = texticlike,
    LEFTARG = citext,
    RIGHTARG = text,
    NEGATOR = !~~,
    RESTRICT = iclikesel,
    JOIN = iclikejoinsel
);


--
-- Name: ~~*; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~~* (
    PROCEDURE = texticlike,
    LEFTARG = citext,
    RIGHTARG = citext,
    NEGATOR = !~~*,
    RESTRICT = iclikesel,
    JOIN = iclikejoinsel
);


--
-- Name: ~~*; Type: OPERATOR; Schema: public; Owner: -
--

CREATE OPERATOR ~~* (
    PROCEDURE = texticlike,
    LEFTARG = citext,
    RIGHTARG = text,
    NEGATOR = !~~*,
    RESTRICT = iclikesel,
    JOIN = iclikejoinsel
);


--
-- Name: citext_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS citext_ops
    DEFAULT FOR TYPE citext USING btree AS
    OPERATOR 1 <(citext,citext) ,
    OPERATOR 2 <=(citext,citext) ,
    OPERATOR 3 =(citext,citext) ,
    OPERATOR 4 >=(citext,citext) ,
    OPERATOR 5 >(citext,citext) ,
    FUNCTION 1 citext_cmp(citext,citext);


--
-- Name: citext_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS citext_ops
    DEFAULT FOR TYPE citext USING hash AS
    OPERATOR 1 =(citext,citext) ,
    FUNCTION 1 citext_hash(citext);


--
-- Name: cube_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS cube_ops
    DEFAULT FOR TYPE cube USING btree AS
    OPERATOR 1 <(cube,cube) ,
    OPERATOR 2 <=(cube,cube) ,
    OPERATOR 3 =(cube,cube) ,
    OPERATOR 4 >=(cube,cube) ,
    OPERATOR 5 >(cube,cube) ,
    FUNCTION 1 cube_cmp(cube,cube);


--
-- Name: gist_cube_ops; Type: OPERATOR CLASS; Schema: public; Owner: -
--

CREATE OPERATOR CLASS gist_cube_ops
    DEFAULT FOR TYPE cube USING gist AS
    OPERATOR 3 &&(cube,cube) ,
    OPERATOR 6 =(cube,cube) ,
    OPERATOR 7 @>(cube,cube) ,
    OPERATOR 8 <@(cube,cube) ,
    OPERATOR 13 @(cube,cube) ,
    OPERATOR 14 ~(cube,cube) ,
    FUNCTION 1 g_cube_consistent(internal,cube,integer,oid,internal) ,
    FUNCTION 2 g_cube_union(internal,internal) ,
    FUNCTION 3 g_cube_compress(internal) ,
    FUNCTION 4 g_cube_decompress(internal) ,
    FUNCTION 5 g_cube_penalty(internal,internal,internal) ,
    FUNCTION 6 g_cube_picksplit(internal,internal) ,
    FUNCTION 7 g_cube_same(cube,cube,internal);


SET search_path = pg_catalog;

--
-- Name: CAST (boolean AS public.citext); Type: CAST; Schema: pg_catalog; Owner: -
--

CREATE CAST (boolean AS public.citext) WITH FUNCTION public.citext(boolean) AS ASSIGNMENT;


--
-- Name: CAST (character AS public.citext); Type: CAST; Schema: pg_catalog; Owner: -
--

CREATE CAST (character AS public.citext) WITH FUNCTION public.citext(character) AS ASSIGNMENT;


--
-- Name: CAST (public.citext AS character); Type: CAST; Schema: pg_catalog; Owner: -
--

CREATE CAST (public.citext AS character) WITHOUT FUNCTION AS ASSIGNMENT;


--
-- Name: CAST (public.citext AS text); Type: CAST; Schema: pg_catalog; Owner: -
--

CREATE CAST (public.citext AS text) WITHOUT FUNCTION AS IMPLICIT;


--
-- Name: CAST (public.citext AS character varying); Type: CAST; Schema: pg_catalog; Owner: -
--

CREATE CAST (public.citext AS character varying) WITHOUT FUNCTION AS IMPLICIT;


--
-- Name: CAST (inet AS public.citext); Type: CAST; Schema: pg_catalog; Owner: -
--

CREATE CAST (inet AS public.citext) WITH FUNCTION public.citext(inet) AS ASSIGNMENT;


--
-- Name: CAST (text AS public.citext); Type: CAST; Schema: pg_catalog; Owner: -
--

CREATE CAST (text AS public.citext) WITHOUT FUNCTION AS ASSIGNMENT;


--
-- Name: CAST (character varying AS public.citext); Type: CAST; Schema: pg_catalog; Owner: -
--

CREATE CAST (character varying AS public.citext) WITHOUT FUNCTION AS ASSIGNMENT;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: event; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE event (
    event_id integer NOT NULL,
    name citext NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    last_mod_user_id integer NOT NULL,
    last_mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: event_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_event_id_seq OWNED BY event.event_id;


--
-- Name: event_log; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE event_log (
    event_log_id integer NOT NULL,
    event_id integer NOT NULL,
    type citext NOT NULL,
    data text,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: event_log_event_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_log_event_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_log_event_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_log_event_log_id_seq OWNED BY event_log.event_log_id;


--
-- Name: event_question; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE event_question (
    event_question_id integer NOT NULL,
    event_id integer NOT NULL,
    question_id integer NOT NULL,
    round_number integer NOT NULL,
    sequence integer NOT NULL,
    start_timestamp timestamp with time zone,
    close_timestamp timestamp with time zone,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: event_question_event_question_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_question_event_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_question_event_question_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_question_event_question_id_seq OWNED BY event_question.event_question_id;


--
-- Name: event_team; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE event_team (
    event_id integer NOT NULL,
    team_id integer NOT NULL,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: question; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE question (
    question_id integer NOT NULL,
    question citext NOT NULL,
    options text,
    answer citext,
    answer_value citext,
    question_type_value character varying DEFAULT 'text'::character varying NOT NULL,
    explanation citext,
    points integer,
    level_id character varying,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    last_mod_user_id integer NOT NULL,
    last_mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: question_question_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_question_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_question_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE question_question_id_seq OWNED BY question.question_id;


--
-- Name: question_type; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE question_type (
    question_type_value character varying NOT NULL,
    name citext NOT NULL,
    description text NOT NULL
);


--
-- Name: school; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE school (
    school_id integer NOT NULL,
    name citext NOT NULL,
    mascot citext,
    nickname citext,
    city citext,
    state_abbrev character varying,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    last_mod_user_id integer NOT NULL,
    last_mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: school_school_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE school_school_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: school_school_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE school_school_id_seq OWNED BY school.school_id;


--
-- Name: session; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE session (
    session_id character varying NOT NULL,
    session_data text,
    expires integer
);


--
-- Name: slide; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE slide (
    slide_id integer NOT NULL,
    name citext NOT NULL,
    url citext NOT NULL,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    last_mod_user_id integer NOT NULL,
    last_mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: slide_slide_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE slide_slide_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: slide_slide_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE slide_slide_id_seq OWNED BY slide.slide_id;


--
-- Name: submission; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE submission (
    submission_id integer NOT NULL,
    event_question_id integer NOT NULL,
    answer citext,
    time_to_answer numeric DEFAULT 0 NOT NULL,
    is_correct boolean,
    points integer,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    last_mod_user_id integer NOT NULL,
    last_mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: submission_submission_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE submission_submission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: submission_submission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE submission_submission_id_seq OWNED BY submission.submission_id;


--
-- Name: team; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE team (
    team_id integer NOT NULL,
    school_id integer,
    name citext NOT NULL,
    mascot citext,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    last_mod_user_id integer NOT NULL,
    last_mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: team_team_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE team_team_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: team_team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE team_team_id_seq OWNED BY team.team_id;


--
-- Name: user_account; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE user_account (
    user_id integer NOT NULL,
    team_id integer,
    school_id integer,
    email citext NOT NULL,
    first_name citext NOT NULL,
    last_name citext NOT NULL,
    password character varying,
    is_admin boolean DEFAULT false NOT NULL,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    last_mod_user_id integer NOT NULL,
    last_mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_account_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_account_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_account_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_account_user_id_seq OWNED BY user_account.user_id;


--
-- Name: user_login; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE user_login (
    user_login_id integer NOT NULL,
    login_ip cidr NOT NULL,
    session_id character varying,
    user_agent text,
    create_user_id integer NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: user_login_user_login_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_login_user_login_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_login_user_login_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_login_user_login_id_seq OWNED BY user_login.user_login_id;


--
-- Name: event_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE event ALTER COLUMN event_id SET DEFAULT nextval('event_event_id_seq'::regclass);


--
-- Name: event_log_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE event_log ALTER COLUMN event_log_id SET DEFAULT nextval('event_log_event_log_id_seq'::regclass);


--
-- Name: event_question_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE event_question ALTER COLUMN event_question_id SET DEFAULT nextval('event_question_event_question_id_seq'::regclass);


--
-- Name: question_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE question ALTER COLUMN question_id SET DEFAULT nextval('question_question_id_seq'::regclass);


--
-- Name: school_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE school ALTER COLUMN school_id SET DEFAULT nextval('school_school_id_seq'::regclass);


--
-- Name: slide_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE slide ALTER COLUMN slide_id SET DEFAULT nextval('slide_slide_id_seq'::regclass);


--
-- Name: submission_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE submission ALTER COLUMN submission_id SET DEFAULT nextval('submission_submission_id_seq'::regclass);


--
-- Name: team_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE team ALTER COLUMN team_id SET DEFAULT nextval('team_team_id_seq'::regclass);


--
-- Name: user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE user_account ALTER COLUMN user_id SET DEFAULT nextval('user_account_user_id_seq'::regclass);


--
-- Name: user_login_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE user_login ALTER COLUMN user_login_id SET DEFAULT nextval('user_login_user_login_id_seq'::regclass);


--
-- Name: event_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY event_log
    ADD CONSTRAINT event_log_pkey PRIMARY KEY (event_log_id);


--
-- Name: event_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_pkey PRIMARY KEY (event_id);


--
-- Name: event_question_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY event_question
    ADD CONSTRAINT event_question_pkey PRIMARY KEY (event_question_id);


--
-- Name: event_team_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY event_team
    ADD CONSTRAINT event_team_pkey PRIMARY KEY (event_id, team_id);


--
-- Name: question_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_pkey PRIMARY KEY (question_id);


--
-- Name: question_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY question_type
    ADD CONSTRAINT question_type_pkey PRIMARY KEY (question_type_value);


--
-- Name: school_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY school
    ADD CONSTRAINT school_pkey PRIMARY KEY (school_id);


--
-- Name: session_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_pkey PRIMARY KEY (session_id);


--
-- Name: slide_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY slide
    ADD CONSTRAINT slide_pkey PRIMARY KEY (slide_id);


--
-- Name: submission_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY submission
    ADD CONSTRAINT submission_pkey PRIMARY KEY (submission_id);


--
-- Name: team_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_pkey PRIMARY KEY (team_id);


--
-- Name: unique_email; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY user_account
    ADD CONSTRAINT unique_email UNIQUE (email);


--
-- Name: unique_school; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY school
    ADD CONSTRAINT unique_school UNIQUE (name);


--
-- Name: unique_team; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY team
    ADD CONSTRAINT unique_team UNIQUE (name);


--
-- Name: user_account_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY user_account
    ADD CONSTRAINT user_account_pkey PRIMARY KEY (user_id);


--
-- Name: user_login_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY user_login
    ADD CONSTRAINT user_login_pkey PRIMARY KEY (user_login_id);


--
-- Name: event_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX event_idx_create_user_id ON event USING btree (create_user_id);


--
-- Name: event_idx_last_mod_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX event_idx_last_mod_user_id ON event USING btree (last_mod_user_id);


--
-- Name: event_log_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX event_log_idx_create_user_id ON event_log USING btree (create_user_id);


--
-- Name: event_question_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX event_question_idx_create_user_id ON event_question USING btree (create_user_id);


--
-- Name: event_team_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX event_team_idx_create_user_id ON event_team USING btree (create_user_id);


--
-- Name: question_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX question_idx_create_user_id ON question USING btree (create_user_id);


--
-- Name: question_idx_last_mod_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX question_idx_last_mod_user_id ON question USING btree (last_mod_user_id);


--
-- Name: school_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX school_idx_create_user_id ON school USING btree (create_user_id);


--
-- Name: school_idx_last_mod_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX school_idx_last_mod_user_id ON school USING btree (last_mod_user_id);


--
-- Name: slide_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX slide_idx_create_user_id ON slide USING btree (create_user_id);


--
-- Name: slide_idx_last_mod_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX slide_idx_last_mod_user_id ON slide USING btree (last_mod_user_id);


--
-- Name: submission_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX submission_idx_create_user_id ON submission USING btree (create_user_id);


--
-- Name: submission_idx_last_mod_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX submission_idx_last_mod_user_id ON submission USING btree (last_mod_user_id);


--
-- Name: team_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX team_idx_create_user_id ON team USING btree (create_user_id);


--
-- Name: team_idx_last_mod_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX team_idx_last_mod_user_id ON team USING btree (last_mod_user_id);


--
-- Name: user_account_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX user_account_idx_create_user_id ON user_account USING btree (create_user_id);


--
-- Name: user_account_idx_last_mod_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX user_account_idx_last_mod_user_id ON user_account USING btree (last_mod_user_id);


--
-- Name: user_login_idx_create_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX user_login_idx_create_user_id ON user_login USING btree (create_user_id);


--
-- Name: event_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: event_last_mod_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event
    ADD CONSTRAINT event_last_mod_user_id_fkey FOREIGN KEY (last_mod_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: event_log_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_log
    ADD CONSTRAINT event_log_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: event_log_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_log
    ADD CONSTRAINT event_log_event_id_fkey FOREIGN KEY (event_id) REFERENCES event(event_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: event_question_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_question
    ADD CONSTRAINT event_question_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: event_question_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_question
    ADD CONSTRAINT event_question_event_id_fkey FOREIGN KEY (event_id) REFERENCES event(event_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: event_question_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_question
    ADD CONSTRAINT event_question_question_id_fkey FOREIGN KEY (question_id) REFERENCES question(question_id) DEFERRABLE;


--
-- Name: event_team_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_team
    ADD CONSTRAINT event_team_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: event_team_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_team
    ADD CONSTRAINT event_team_event_id_fkey FOREIGN KEY (event_id) REFERENCES event(event_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: event_team_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_team
    ADD CONSTRAINT event_team_team_id_fkey FOREIGN KEY (team_id) REFERENCES team(team_id) DEFERRABLE;


--
-- Name: question_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: question_last_mod_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_last_mod_user_id_fkey FOREIGN KEY (last_mod_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: question_question_type_value_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question
    ADD CONSTRAINT question_question_type_value_fkey FOREIGN KEY (question_type_value) REFERENCES question_type(question_type_value) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: school_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY school
    ADD CONSTRAINT school_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: school_last_mod_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY school
    ADD CONSTRAINT school_last_mod_user_id_fkey FOREIGN KEY (last_mod_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: slide_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slide
    ADD CONSTRAINT slide_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: slide_last_mod_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY slide
    ADD CONSTRAINT slide_last_mod_user_id_fkey FOREIGN KEY (last_mod_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: submission_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission
    ADD CONSTRAINT submission_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: submission_event_question_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission
    ADD CONSTRAINT submission_event_question_id_fkey FOREIGN KEY (event_question_id) REFERENCES event_question(event_question_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: submission_last_mod_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY submission
    ADD CONSTRAINT submission_last_mod_user_id_fkey FOREIGN KEY (last_mod_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: team_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: team_last_mod_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_last_mod_user_id_fkey FOREIGN KEY (last_mod_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: team_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY team
    ADD CONSTRAINT team_school_id_fkey FOREIGN KEY (school_id) REFERENCES school(school_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: user_account_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_account
    ADD CONSTRAINT user_account_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: user_account_last_mod_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_account
    ADD CONSTRAINT user_account_last_mod_user_id_fkey FOREIGN KEY (last_mod_user_id) REFERENCES user_account(user_id) DEFERRABLE;


--
-- Name: user_account_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_account
    ADD CONSTRAINT user_account_school_id_fkey FOREIGN KEY (school_id) REFERENCES school(school_id) DEFERRABLE;


--
-- Name: user_account_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_account
    ADD CONSTRAINT user_account_team_id_fkey FOREIGN KEY (team_id) REFERENCES team(team_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: user_login_create_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_login
    ADD CONSTRAINT user_login_create_user_id_fkey FOREIGN KEY (create_user_id) REFERENCES user_account(user_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- PostgreSQL database dump complete
--


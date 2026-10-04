/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:claimdesk_server/src/generated/caption_run.dart' as _iknvw4pb;
import 'package:claimdesk_server/src/generated/custody_event.dart' as _ie8uz96n;
import 'package:claimdesk_server/src/generated/found_item.dart' as _iskydu8k;
import 'package:claimdesk_server/src/generated/history_entry.dart' as _iv8y2aad;
import 'package:claimdesk_server/src/generated/lost_report.dart' as _i63i6mgk;
import 'package:claimdesk_server/src/generated/match_card.dart' as _i1d6w25f;
import 'package:claimdesk_server/src/generated/report_answer.dart' as _in630fta;
import 'package:claimdesk_server/src/generated/staff_membership.dart'
    as _iugziyav;
import 'package:claimdesk_server/src/generated/zone.dart' as _irlgv1kd;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'already_released_exception.dart' as _igbhs0au;
import 'audit_event.dart' as _irb38j2y;
import 'audit_payload.dart' as _imod1ub6;
import 'caption_run.dart' as _igo1wxdq;
import 'create_item_input.dart' as _i6s4pod3;
import 'custody_event.dart' as _iq6v1376;
import 'desk_event.dart' as _iz4ruabw;
import 'desk_summary.dart' as _ip6mi6ty;
import 'dispose_input.dart' as _iyfw2vy3;
import 'found_item.dart' as _i52cv103;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'history_entry.dart' as _i85vle09;
import 'item_attributes.dart' as _i43d0yeo;
import 'item_filter.dart' as _ibf35g9z;
import 'item_match.dart' as _i989z6nt;
import 'item_patch.dart' as _i3b5hl76;
import 'item_status.dart' as _ibbyonnn;
import 'lost_report.dart' as _iyhihx8i;
import 'match_card.dart' as _ig904ein;
import 'match_explanation.dart' as _i7ltg7v2;
import 'match_state.dart' as _idznkk1k;
import 'match_state_exception.dart' as _inl9arvk;
import 'not_a_member_exception.dart' as _ilheyvx1;
import 'photo_upload_ticket.dart' as _ivh14x5g;
import 'release_input.dart' as _ixt06mmk;
import 'release_record.dart' as _ieeq0b1h;
import 'release_refused_exception.dart' as _ir3sugu7;
import 'release_summary.dart' as _ij181cah;
import 'report_answer.dart' as _ihkjjm70;
import 'report_filter.dart' as _i520f1xg;
import 'report_status.dart' as _i8pcsu0p;
import 'retention_policy.dart' as _ic8ul1lq;
import 'staff_membership.dart' as _isosyfem;
import 'staff_role.dart' as _i120pgjk;
import 'transfer_input.dart' as _ibjdv4jl;
import 'value_band.dart' as _iphilgki;
import 'venue.dart' as _in4rmfby;
import 'work_item.dart' as _ik77na07;
import 'work_payload.dart' as _ib3jfnwt;
import 'work_state.dart' as _i6iais05;
import 'zone.dart' as _ixcxr4o1;
export 'already_released_exception.dart';
export 'audit_event.dart';
export 'audit_payload.dart';
export 'caption_run.dart';
export 'create_item_input.dart';
export 'custody_event.dart';
export 'desk_event.dart';
export 'desk_summary.dart';
export 'dispose_input.dart';
export 'found_item.dart';
export 'greetings/greeting.dart';
export 'history_entry.dart';
export 'item_attributes.dart';
export 'item_filter.dart';
export 'item_match.dart';
export 'item_patch.dart';
export 'item_status.dart';
export 'lost_report.dart';
export 'match_card.dart';
export 'match_explanation.dart';
export 'match_state.dart';
export 'match_state_exception.dart';
export 'not_a_member_exception.dart';
export 'photo_upload_ticket.dart';
export 'release_input.dart';
export 'release_record.dart';
export 'release_refused_exception.dart';
export 'release_summary.dart';
export 'report_answer.dart';
export 'report_filter.dart';
export 'report_status.dart';
export 'retention_policy.dart';
export 'staff_membership.dart';
export 'staff_role.dart';
export 'transfer_input.dart';
export 'value_band.dart';
export 'venue.dart';
export 'work_item.dart';
export 'work_payload.dart';
export 'work_state.dart';
export 'zone.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'audit_event',
      dartName: 'AuditEvent',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'entityType',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'entityId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'action',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'actorAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'payload',
          columnType: _isp.ColumnType.jsonb,
          isNullable: true,
          dartType: 'protocol:AuditPayload?',
        ),
        _isp.ColumnDefinition(
          name: 'at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'audit_event_entity_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityType',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'entityId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'at',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'caption_run',
      dartName: 'CaptionRun',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'itemId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'provider',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'modelId',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'promptVersion',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'outcome',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'latencyMs',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'inputTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'outputTokens',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'errorMessage',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'caption_run_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'caption_run_fk_1',
          columns: ['itemId'],
          referenceTable: 'found_item',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'caption_run_item_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'itemId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'custody_event',
      dartName: 'CustodyEvent',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'itemId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'fromLocation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'toLocation',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'reference',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'byAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'custody_event_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'custody_event_fk_1',
          columns: ['itemId'],
          referenceTable: 'found_item',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'custody_event_item_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'itemId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'found_item',
      dartName: 'FoundItem',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'zoneId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ItemStatus',
          columnDefault: '\'intake\'',
        ),
        _isp.ColumnDefinition(
          name: 'refCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'photoPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'thumbPath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'restricted',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'attributes',
          columnType: _isp.ColumnType.jsonb,
          isNullable: true,
          dartType: 'protocol:ItemAttributes?',
        ),
        _isp.ColumnDefinition(
          name: 'captionText',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'embedding',
          columnType: _isp.ColumnType.vector,
          isNullable: true,
          dartType: 'Vector(1536)?',
          vectorDimension: 1536,
        ),
        _isp.ColumnDefinition(
          name: 'embeddingModel',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'valueBand',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ValueBand',
          columnDefault: '\'under20\'',
        ),
        _isp.ColumnDefinition(
          name: 'storageBin',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'privateNotes',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'finderName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'foundAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'loggedByAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'holdUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'handoffDueAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'found_item_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'found_item_fk_1',
          columns: ['zoneId'],
          referenceTable: 'zone',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'found_item__venueId__refCode__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'venueId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'refCode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'found_item_venue_status_found_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'venueId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'foundAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'found_item_attributes_gin_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'attributes',
            ),
          ],
          type: 'gin',
          isUnique: false,
          isPrimary: false,
          ginOperatorClass: _isp.GinOperatorClass.jsonbPathOps,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'item_match',
      dartName: 'ItemMatch',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'reportId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'itemId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MatchState',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'score',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'label',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'rank',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'explanation',
          columnType: _isp.ColumnType.jsonb,
          isNullable: false,
          dartType: 'protocol:MatchExplanation',
        ),
        _isp.ColumnDefinition(
          name: 'algorithmVersion',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'decidedByAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'decidedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'item_match_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'item_match_fk_1',
          columns: ['reportId'],
          referenceTable: 'lost_report',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'item_match_fk_2',
          columns: ['itemId'],
          referenceTable: 'found_item',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'item_match_report_item_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'reportId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'itemId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'item_match_venue_state_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'venueId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'state',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'lost_report',
      dartName: 'LostReport',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ReportStatus',
          columnDefault: '\'received\'',
        ),
        _isp.ColumnDefinition(
          name: 'refCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'publicToken',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'rawText',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'categoryHint',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'colourHints',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<String>',
        ),
        _isp.ColumnDefinition(
          name: 'brandHint',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'zoneId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'whereText',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'lostAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'lostAtFuzzyDays',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'ownerOnlyDetails',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'contactEmail',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'ownerName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'attributes',
          columnType: _isp.ColumnType.jsonb,
          isNullable: true,
          dartType: 'protocol:ItemAttributes?',
        ),
        _isp.ColumnDefinition(
          name: 'embedding',
          columnType: _isp.ColumnType.vector,
          isNullable: true,
          dartType: 'Vector(1536)?',
          vectorDimension: 1536,
        ),
        _isp.ColumnDefinition(
          name: 'embeddingModel',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'duplicateOfReportId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'ipHash',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'closedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'contactPurgedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'lost_report_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'lost_report_fk_1',
          columns: ['zoneId'],
          referenceTable: 'zone',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'lost_report__venueId__refCode__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'venueId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'refCode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'lost_report__publicToken__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'publicToken',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'lost_report_venue_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'venueId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'status',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'createdAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'release_record',
      dartName: 'ReleaseRecord',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'itemId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'reportId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'claimantName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'idTypeSeen',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'detailsMatched',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'describedBeforeViewing',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'thirdPartyAuthorisationNote',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'signaturePath',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'releasedByAuthUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'releasedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'release_record_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'release_record_fk_1',
          columns: ['itemId'],
          referenceTable: 'found_item',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'release_record_fk_2',
          columns: ['reportId'],
          referenceTable: 'lost_report',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.setNull,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'release_record_item_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'itemId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'report_answer',
      dartName: 'ReportAnswer',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'reportId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'matchId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'question',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'answer',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'report_answer_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'report_answer_fk_1',
          columns: ['reportId'],
          referenceTable: 'lost_report',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'report_answer_fk_2',
          columns: ['matchId'],
          referenceTable: 'item_match',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'report_answer_report_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'reportId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'staff_membership',
      dartName: 'StaffMembership',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:StaffRole',
          columnDefault: '\'staff\'',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'staff_membership_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'staff_membership_user_venue_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'venueId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'venue',
      dartName: 'Venue',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'slug',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'timezone',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'America/New_York\'',
        ),
        _isp.ColumnDefinition(
          name: 'deskHours',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'pickupInstructions',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'retentionPolicy',
          columnType: _isp.ColumnType.jsonb,
          isNullable: true,
          dartType: 'protocol:RetentionPolicy?',
        ),
        _isp.ColumnDefinition(
          name: 'policeHandoffThresholdCents',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '2000',
        ),
        _isp.ColumnDefinition(
          name: 'policeHandoffDays',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '10',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'venue__slug__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'slug',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'work_item',
      dartName: 'WorkItem',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'payload',
          columnType: _isp.ColumnType.jsonb,
          isNullable: false,
          dartType: 'protocol:WorkPayload',
        ),
        _isp.ColumnDefinition(
          name: 'identifier',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'runAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'state',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:WorkState',
          columnDefault: '\'pending\'',
        ),
        _isp.ColumnDefinition(
          name: 'leaseUntil',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'attempts',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'maxAttempts',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '5',
        ),
        _isp.ColumnDefinition(
          name: 'lastError',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'completedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'work_item_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'work_item__identifier__unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'identifier',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'work_item_state_run_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'state',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'runAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'zone',
      dartName: 'Zone',
      schema: 'public',
      module: 'claimdesk',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'venueId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sortOrder',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'adjacentZoneIds',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<UuidValue>',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'zone_fk_0',
          columns: ['venueId'],
          referenceTable: 'venue',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'zone_venue_name_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'venueId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'name',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _igbhs0au.AlreadyReleasedException) {
      return _igbhs0au.AlreadyReleasedException.fromJson(data) as T;
    }
    if (t == _irb38j2y.AuditEvent) {
      return _irb38j2y.AuditEvent.fromJson(data) as T;
    }
    if (t == _imod1ub6.AuditPayload) {
      return _imod1ub6.AuditPayload.fromJson(data) as T;
    }
    if (t == _igo1wxdq.CaptionRun) {
      return _igo1wxdq.CaptionRun.fromJson(data) as T;
    }
    if (t == _i6s4pod3.CreateItemInput) {
      return _i6s4pod3.CreateItemInput.fromJson(data) as T;
    }
    if (t == _iq6v1376.CustodyEvent) {
      return _iq6v1376.CustodyEvent.fromJson(data) as T;
    }
    if (t == _iz4ruabw.DeskEvent) {
      return _iz4ruabw.DeskEvent.fromJson(data) as T;
    }
    if (t == _ip6mi6ty.DeskSummary) {
      return _ip6mi6ty.DeskSummary.fromJson(data) as T;
    }
    if (t == _iyfw2vy3.DisposeInput) {
      return _iyfw2vy3.DisposeInput.fromJson(data) as T;
    }
    if (t == _i52cv103.FoundItem) {
      return _i52cv103.FoundItem.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _i85vle09.HistoryEntry) {
      return _i85vle09.HistoryEntry.fromJson(data) as T;
    }
    if (t == _i43d0yeo.ItemAttributes) {
      return _i43d0yeo.ItemAttributes.fromJson(data) as T;
    }
    if (t == _ibf35g9z.ItemFilter) {
      return _ibf35g9z.ItemFilter.fromJson(data) as T;
    }
    if (t == _i989z6nt.ItemMatch) {
      return _i989z6nt.ItemMatch.fromJson(data) as T;
    }
    if (t == _i3b5hl76.ItemPatch) {
      return _i3b5hl76.ItemPatch.fromJson(data) as T;
    }
    if (t == _ibbyonnn.ItemStatus) {
      return _ibbyonnn.ItemStatus.fromJson(data) as T;
    }
    if (t == _iyhihx8i.LostReport) {
      return _iyhihx8i.LostReport.fromJson(data) as T;
    }
    if (t == _ig904ein.MatchCard) {
      return _ig904ein.MatchCard.fromJson(data) as T;
    }
    if (t == _i7ltg7v2.MatchExplanation) {
      return _i7ltg7v2.MatchExplanation.fromJson(data) as T;
    }
    if (t == _idznkk1k.MatchState) {
      return _idznkk1k.MatchState.fromJson(data) as T;
    }
    if (t == _inl9arvk.MatchStateException) {
      return _inl9arvk.MatchStateException.fromJson(data) as T;
    }
    if (t == _ilheyvx1.NotAMemberException) {
      return _ilheyvx1.NotAMemberException.fromJson(data) as T;
    }
    if (t == _ivh14x5g.PhotoUploadTicket) {
      return _ivh14x5g.PhotoUploadTicket.fromJson(data) as T;
    }
    if (t == _ixt06mmk.ReleaseInput) {
      return _ixt06mmk.ReleaseInput.fromJson(data) as T;
    }
    if (t == _ieeq0b1h.ReleaseRecord) {
      return _ieeq0b1h.ReleaseRecord.fromJson(data) as T;
    }
    if (t == _ir3sugu7.ReleaseRefusedException) {
      return _ir3sugu7.ReleaseRefusedException.fromJson(data) as T;
    }
    if (t == _ij181cah.ReleaseSummary) {
      return _ij181cah.ReleaseSummary.fromJson(data) as T;
    }
    if (t == _ihkjjm70.ReportAnswer) {
      return _ihkjjm70.ReportAnswer.fromJson(data) as T;
    }
    if (t == _i520f1xg.ReportFilter) {
      return _i520f1xg.ReportFilter.fromJson(data) as T;
    }
    if (t == _i8pcsu0p.ReportStatus) {
      return _i8pcsu0p.ReportStatus.fromJson(data) as T;
    }
    if (t == _ic8ul1lq.RetentionPolicy) {
      return _ic8ul1lq.RetentionPolicy.fromJson(data) as T;
    }
    if (t == _isosyfem.StaffMembership) {
      return _isosyfem.StaffMembership.fromJson(data) as T;
    }
    if (t == _i120pgjk.StaffRole) {
      return _i120pgjk.StaffRole.fromJson(data) as T;
    }
    if (t == _ibjdv4jl.TransferInput) {
      return _ibjdv4jl.TransferInput.fromJson(data) as T;
    }
    if (t == _iphilgki.ValueBand) {
      return _iphilgki.ValueBand.fromJson(data) as T;
    }
    if (t == _in4rmfby.Venue) {
      return _in4rmfby.Venue.fromJson(data) as T;
    }
    if (t == _ik77na07.WorkItem) {
      return _ik77na07.WorkItem.fromJson(data) as T;
    }
    if (t == _ib3jfnwt.WorkPayload) {
      return _ib3jfnwt.WorkPayload.fromJson(data) as T;
    }
    if (t == _i6iais05.WorkState) {
      return _i6iais05.WorkState.fromJson(data) as T;
    }
    if (t == _ixcxr4o1.Zone) {
      return _ixcxr4o1.Zone.fromJson(data) as T;
    }
    if (t == _is.getType<_igbhs0au.AlreadyReleasedException?>()) {
      return (data != null
              ? _igbhs0au.AlreadyReleasedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_irb38j2y.AuditEvent?>()) {
      return (data != null ? _irb38j2y.AuditEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_imod1ub6.AuditPayload?>()) {
      return (data != null ? _imod1ub6.AuditPayload.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_igo1wxdq.CaptionRun?>()) {
      return (data != null ? _igo1wxdq.CaptionRun.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6s4pod3.CreateItemInput?>()) {
      return (data != null ? _i6s4pod3.CreateItemInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iq6v1376.CustodyEvent?>()) {
      return (data != null ? _iq6v1376.CustodyEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iz4ruabw.DeskEvent?>()) {
      return (data != null ? _iz4ruabw.DeskEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ip6mi6ty.DeskSummary?>()) {
      return (data != null ? _ip6mi6ty.DeskSummary.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iyfw2vy3.DisposeInput?>()) {
      return (data != null ? _iyfw2vy3.DisposeInput.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i52cv103.FoundItem?>()) {
      return (data != null ? _i52cv103.FoundItem.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i85vle09.HistoryEntry?>()) {
      return (data != null ? _i85vle09.HistoryEntry.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i43d0yeo.ItemAttributes?>()) {
      return (data != null ? _i43d0yeo.ItemAttributes.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ibf35g9z.ItemFilter?>()) {
      return (data != null ? _ibf35g9z.ItemFilter.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i989z6nt.ItemMatch?>()) {
      return (data != null ? _i989z6nt.ItemMatch.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3b5hl76.ItemPatch?>()) {
      return (data != null ? _i3b5hl76.ItemPatch.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ibbyonnn.ItemStatus?>()) {
      return (data != null ? _ibbyonnn.ItemStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iyhihx8i.LostReport?>()) {
      return (data != null ? _iyhihx8i.LostReport.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ig904ein.MatchCard?>()) {
      return (data != null ? _ig904ein.MatchCard.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i7ltg7v2.MatchExplanation?>()) {
      return (data != null ? _i7ltg7v2.MatchExplanation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idznkk1k.MatchState?>()) {
      return (data != null ? _idznkk1k.MatchState.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_inl9arvk.MatchStateException?>()) {
      return (data != null
              ? _inl9arvk.MatchStateException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ilheyvx1.NotAMemberException?>()) {
      return (data != null
              ? _ilheyvx1.NotAMemberException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ivh14x5g.PhotoUploadTicket?>()) {
      return (data != null ? _ivh14x5g.PhotoUploadTicket.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixt06mmk.ReleaseInput?>()) {
      return (data != null ? _ixt06mmk.ReleaseInput.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ieeq0b1h.ReleaseRecord?>()) {
      return (data != null ? _ieeq0b1h.ReleaseRecord.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ir3sugu7.ReleaseRefusedException?>()) {
      return (data != null
              ? _ir3sugu7.ReleaseRefusedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ij181cah.ReleaseSummary?>()) {
      return (data != null ? _ij181cah.ReleaseSummary.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ihkjjm70.ReportAnswer?>()) {
      return (data != null ? _ihkjjm70.ReportAnswer.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i520f1xg.ReportFilter?>()) {
      return (data != null ? _i520f1xg.ReportFilter.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8pcsu0p.ReportStatus?>()) {
      return (data != null ? _i8pcsu0p.ReportStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ic8ul1lq.RetentionPolicy?>()) {
      return (data != null ? _ic8ul1lq.RetentionPolicy.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_isosyfem.StaffMembership?>()) {
      return (data != null ? _isosyfem.StaffMembership.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i120pgjk.StaffRole?>()) {
      return (data != null ? _i120pgjk.StaffRole.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ibjdv4jl.TransferInput?>()) {
      return (data != null ? _ibjdv4jl.TransferInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iphilgki.ValueBand?>()) {
      return (data != null ? _iphilgki.ValueBand.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_in4rmfby.Venue?>()) {
      return (data != null ? _in4rmfby.Venue.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ik77na07.WorkItem?>()) {
      return (data != null ? _ik77na07.WorkItem.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ib3jfnwt.WorkPayload?>()) {
      return (data != null ? _ib3jfnwt.WorkPayload.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6iais05.WorkState?>()) {
      return (data != null ? _i6iais05.WorkState.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ixcxr4o1.Zone?>()) {
      return (data != null ? _ixcxr4o1.Zone.fromJson(data) : null) as T;
    }
    if (t == Map<String, String>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<String>(v)),
          )
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == _is.getType<List<String>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<String>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i52cv103.FoundItem>) {
      return (data as List)
              .map((e) => deserialize<_i52cv103.FoundItem>(e))
              .toList()
          as T;
    }
    if (t == Map<String, int>) {
      return (data as Map).map(
            (k, v) => MapEntry(deserialize<String>(k), deserialize<int>(v)),
          )
          as T;
    }
    if (t == List<_is.UuidValue>) {
      return (data as List).map((e) => deserialize<_is.UuidValue>(e)).toList()
          as T;
    }
    if (t ==
        _is
            .getType<
              ({
                _is.UuidValue staffId,
                _is.UuidValue supervisorId,
                _is.UuidValue venueId,
              })
            >()) {
      return (
            staffId: deserialize<_is.UuidValue>(
              ((data as Map)['n'] as Map)['staffId'],
            ),
            supervisorId: deserialize<_is.UuidValue>(data['n']['supervisorId']),
            venueId: deserialize<_is.UuidValue>(data['n']['venueId']),
          )
          as T;
    }
    if (t == List<_iskydu8k.FoundItem>) {
      return (data as List)
              .map((e) => deserialize<_iskydu8k.FoundItem>(e))
              .toList()
          as T;
    }
    if (t == List<_iknvw4pb.CaptionRun>) {
      return (data as List)
              .map((e) => deserialize<_iknvw4pb.CaptionRun>(e))
              .toList()
          as T;
    }
    if (t == List<_iv8y2aad.HistoryEntry>) {
      return (data as List)
              .map((e) => deserialize<_iv8y2aad.HistoryEntry>(e))
              .toList()
          as T;
    }
    if (t == List<_ie8uz96n.CustodyEvent>) {
      return (data as List)
              .map((e) => deserialize<_ie8uz96n.CustodyEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_in630fta.ReportAnswer>) {
      return (data as List)
              .map((e) => deserialize<_in630fta.ReportAnswer>(e))
              .toList()
          as T;
    }
    if (t == List<_i1d6w25f.MatchCard>) {
      return (data as List)
              .map((e) => deserialize<_i1d6w25f.MatchCard>(e))
              .toList()
          as T;
    }
    if (t == List<_i63i6mgk.LostReport>) {
      return (data as List)
              .map((e) => deserialize<_i63i6mgk.LostReport>(e))
              .toList()
          as T;
    }
    if (t == List<_iugziyav.StaffMembership>) {
      return (data as List)
              .map((e) => deserialize<_iugziyav.StaffMembership>(e))
              .toList()
          as T;
    }
    if (t == List<_irlgv1kd.Zone>) {
      return (data as List).map((e) => deserialize<_irlgv1kd.Zone>(e)).toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _igbhs0au.AlreadyReleasedException => 'AlreadyReleasedException',
      _irb38j2y.AuditEvent => 'AuditEvent',
      _imod1ub6.AuditPayload => 'AuditPayload',
      _igo1wxdq.CaptionRun => 'CaptionRun',
      _i6s4pod3.CreateItemInput => 'CreateItemInput',
      _iq6v1376.CustodyEvent => 'CustodyEvent',
      _iz4ruabw.DeskEvent => 'DeskEvent',
      _ip6mi6ty.DeskSummary => 'DeskSummary',
      _iyfw2vy3.DisposeInput => 'DisposeInput',
      _i52cv103.FoundItem => 'FoundItem',
      _izw8z7ou.Greeting => 'Greeting',
      _i85vle09.HistoryEntry => 'HistoryEntry',
      _i43d0yeo.ItemAttributes => 'ItemAttributes',
      _ibf35g9z.ItemFilter => 'ItemFilter',
      _i989z6nt.ItemMatch => 'ItemMatch',
      _i3b5hl76.ItemPatch => 'ItemPatch',
      _ibbyonnn.ItemStatus => 'ItemStatus',
      _iyhihx8i.LostReport => 'LostReport',
      _ig904ein.MatchCard => 'MatchCard',
      _i7ltg7v2.MatchExplanation => 'MatchExplanation',
      _idznkk1k.MatchState => 'MatchState',
      _inl9arvk.MatchStateException => 'MatchStateException',
      _ilheyvx1.NotAMemberException => 'NotAMemberException',
      _ivh14x5g.PhotoUploadTicket => 'PhotoUploadTicket',
      _ixt06mmk.ReleaseInput => 'ReleaseInput',
      _ieeq0b1h.ReleaseRecord => 'ReleaseRecord',
      _ir3sugu7.ReleaseRefusedException => 'ReleaseRefusedException',
      _ij181cah.ReleaseSummary => 'ReleaseSummary',
      _ihkjjm70.ReportAnswer => 'ReportAnswer',
      _i520f1xg.ReportFilter => 'ReportFilter',
      _i8pcsu0p.ReportStatus => 'ReportStatus',
      _ic8ul1lq.RetentionPolicy => 'RetentionPolicy',
      _isosyfem.StaffMembership => 'StaffMembership',
      _i120pgjk.StaffRole => 'StaffRole',
      _ibjdv4jl.TransferInput => 'TransferInput',
      _iphilgki.ValueBand => 'ValueBand',
      _in4rmfby.Venue => 'Venue',
      _ik77na07.WorkItem => 'WorkItem',
      _ib3jfnwt.WorkPayload => 'WorkPayload',
      _i6iais05.WorkState => 'WorkState',
      _ixcxr4o1.Zone => 'Zone',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('claimdesk.', '');
    }

    switch (data) {
      case _igbhs0au.AlreadyReleasedException():
        return 'AlreadyReleasedException';
      case _irb38j2y.AuditEvent():
        return 'AuditEvent';
      case _imod1ub6.AuditPayload():
        return 'AuditPayload';
      case _igo1wxdq.CaptionRun():
        return 'CaptionRun';
      case _i6s4pod3.CreateItemInput():
        return 'CreateItemInput';
      case _iq6v1376.CustodyEvent():
        return 'CustodyEvent';
      case _iz4ruabw.DeskEvent():
        return 'DeskEvent';
      case _ip6mi6ty.DeskSummary():
        return 'DeskSummary';
      case _iyfw2vy3.DisposeInput():
        return 'DisposeInput';
      case _i52cv103.FoundItem():
        return 'FoundItem';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _i85vle09.HistoryEntry():
        return 'HistoryEntry';
      case _i43d0yeo.ItemAttributes():
        return 'ItemAttributes';
      case _ibf35g9z.ItemFilter():
        return 'ItemFilter';
      case _i989z6nt.ItemMatch():
        return 'ItemMatch';
      case _i3b5hl76.ItemPatch():
        return 'ItemPatch';
      case _ibbyonnn.ItemStatus():
        return 'ItemStatus';
      case _iyhihx8i.LostReport():
        return 'LostReport';
      case _ig904ein.MatchCard():
        return 'MatchCard';
      case _i7ltg7v2.MatchExplanation():
        return 'MatchExplanation';
      case _idznkk1k.MatchState():
        return 'MatchState';
      case _inl9arvk.MatchStateException():
        return 'MatchStateException';
      case _ilheyvx1.NotAMemberException():
        return 'NotAMemberException';
      case _ivh14x5g.PhotoUploadTicket():
        return 'PhotoUploadTicket';
      case _ixt06mmk.ReleaseInput():
        return 'ReleaseInput';
      case _ieeq0b1h.ReleaseRecord():
        return 'ReleaseRecord';
      case _ir3sugu7.ReleaseRefusedException():
        return 'ReleaseRefusedException';
      case _ij181cah.ReleaseSummary():
        return 'ReleaseSummary';
      case _ihkjjm70.ReportAnswer():
        return 'ReportAnswer';
      case _i520f1xg.ReportFilter():
        return 'ReportFilter';
      case _i8pcsu0p.ReportStatus():
        return 'ReportStatus';
      case _ic8ul1lq.RetentionPolicy():
        return 'RetentionPolicy';
      case _isosyfem.StaffMembership():
        return 'StaffMembership';
      case _i120pgjk.StaffRole():
        return 'StaffRole';
      case _ibjdv4jl.TransferInput():
        return 'TransferInput';
      case _iphilgki.ValueBand():
        return 'ValueBand';
      case _in4rmfby.Venue():
        return 'Venue';
      case _ik77na07.WorkItem():
        return 'WorkItem';
      case _ib3jfnwt.WorkPayload():
        return 'WorkPayload';
      case _i6iais05.WorkState():
        return 'WorkState';
      case _ixcxr4o1.Zone():
        return 'Zone';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AlreadyReleasedException') {
      return deserialize<_igbhs0au.AlreadyReleasedException>(data['data']);
    }
    if (dataClassName == 'AuditEvent') {
      return deserialize<_irb38j2y.AuditEvent>(data['data']);
    }
    if (dataClassName == 'AuditPayload') {
      return deserialize<_imod1ub6.AuditPayload>(data['data']);
    }
    if (dataClassName == 'CaptionRun') {
      return deserialize<_igo1wxdq.CaptionRun>(data['data']);
    }
    if (dataClassName == 'CreateItemInput') {
      return deserialize<_i6s4pod3.CreateItemInput>(data['data']);
    }
    if (dataClassName == 'CustodyEvent') {
      return deserialize<_iq6v1376.CustodyEvent>(data['data']);
    }
    if (dataClassName == 'DeskEvent') {
      return deserialize<_iz4ruabw.DeskEvent>(data['data']);
    }
    if (dataClassName == 'DeskSummary') {
      return deserialize<_ip6mi6ty.DeskSummary>(data['data']);
    }
    if (dataClassName == 'DisposeInput') {
      return deserialize<_iyfw2vy3.DisposeInput>(data['data']);
    }
    if (dataClassName == 'FoundItem') {
      return deserialize<_i52cv103.FoundItem>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'HistoryEntry') {
      return deserialize<_i85vle09.HistoryEntry>(data['data']);
    }
    if (dataClassName == 'ItemAttributes') {
      return deserialize<_i43d0yeo.ItemAttributes>(data['data']);
    }
    if (dataClassName == 'ItemFilter') {
      return deserialize<_ibf35g9z.ItemFilter>(data['data']);
    }
    if (dataClassName == 'ItemMatch') {
      return deserialize<_i989z6nt.ItemMatch>(data['data']);
    }
    if (dataClassName == 'ItemPatch') {
      return deserialize<_i3b5hl76.ItemPatch>(data['data']);
    }
    if (dataClassName == 'ItemStatus') {
      return deserialize<_ibbyonnn.ItemStatus>(data['data']);
    }
    if (dataClassName == 'LostReport') {
      return deserialize<_iyhihx8i.LostReport>(data['data']);
    }
    if (dataClassName == 'MatchCard') {
      return deserialize<_ig904ein.MatchCard>(data['data']);
    }
    if (dataClassName == 'MatchExplanation') {
      return deserialize<_i7ltg7v2.MatchExplanation>(data['data']);
    }
    if (dataClassName == 'MatchState') {
      return deserialize<_idznkk1k.MatchState>(data['data']);
    }
    if (dataClassName == 'MatchStateException') {
      return deserialize<_inl9arvk.MatchStateException>(data['data']);
    }
    if (dataClassName == 'NotAMemberException') {
      return deserialize<_ilheyvx1.NotAMemberException>(data['data']);
    }
    if (dataClassName == 'PhotoUploadTicket') {
      return deserialize<_ivh14x5g.PhotoUploadTicket>(data['data']);
    }
    if (dataClassName == 'ReleaseInput') {
      return deserialize<_ixt06mmk.ReleaseInput>(data['data']);
    }
    if (dataClassName == 'ReleaseRecord') {
      return deserialize<_ieeq0b1h.ReleaseRecord>(data['data']);
    }
    if (dataClassName == 'ReleaseRefusedException') {
      return deserialize<_ir3sugu7.ReleaseRefusedException>(data['data']);
    }
    if (dataClassName == 'ReleaseSummary') {
      return deserialize<_ij181cah.ReleaseSummary>(data['data']);
    }
    if (dataClassName == 'ReportAnswer') {
      return deserialize<_ihkjjm70.ReportAnswer>(data['data']);
    }
    if (dataClassName == 'ReportFilter') {
      return deserialize<_i520f1xg.ReportFilter>(data['data']);
    }
    if (dataClassName == 'ReportStatus') {
      return deserialize<_i8pcsu0p.ReportStatus>(data['data']);
    }
    if (dataClassName == 'RetentionPolicy') {
      return deserialize<_ic8ul1lq.RetentionPolicy>(data['data']);
    }
    if (dataClassName == 'StaffMembership') {
      return deserialize<_isosyfem.StaffMembership>(data['data']);
    }
    if (dataClassName == 'StaffRole') {
      return deserialize<_i120pgjk.StaffRole>(data['data']);
    }
    if (dataClassName == 'TransferInput') {
      return deserialize<_ibjdv4jl.TransferInput>(data['data']);
    }
    if (dataClassName == 'ValueBand') {
      return deserialize<_iphilgki.ValueBand>(data['data']);
    }
    if (dataClassName == 'Venue') {
      return deserialize<_in4rmfby.Venue>(data['data']);
    }
    if (dataClassName == 'WorkItem') {
      return deserialize<_ik77na07.WorkItem>(data['data']);
    }
    if (dataClassName == 'WorkPayload') {
      return deserialize<_ib3jfnwt.WorkPayload>(data['data']);
    }
    if (dataClassName == 'WorkState') {
      return deserialize<_i6iais05.WorkState>(data['data']);
    }
    if (dataClassName == 'Zone') {
      return deserialize<_ixcxr4o1.Zone>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('claimdesk', this);
    _iacs.Protocol().registerHostProtocol('claimdesk', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _irb38j2y.AuditEvent:
        return _irb38j2y.AuditEvent.t;
      case _igo1wxdq.CaptionRun:
        return _igo1wxdq.CaptionRun.t;
      case _iq6v1376.CustodyEvent:
        return _iq6v1376.CustodyEvent.t;
      case _i52cv103.FoundItem:
        return _i52cv103.FoundItem.t;
      case _i989z6nt.ItemMatch:
        return _i989z6nt.ItemMatch.t;
      case _iyhihx8i.LostReport:
        return _iyhihx8i.LostReport.t;
      case _ieeq0b1h.ReleaseRecord:
        return _ieeq0b1h.ReleaseRecord.t;
      case _ihkjjm70.ReportAnswer:
        return _ihkjjm70.ReportAnswer.t;
      case _isosyfem.StaffMembership:
        return _isosyfem.StaffMembership.t;
      case _in4rmfby.Venue:
        return _in4rmfby.Venue.t;
      case _ik77na07.WorkItem:
        return _ik77na07.WorkItem.t;
      case _ixcxr4o1.Zone:
        return _ixcxr4o1.Zone.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'claimdesk';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    if (record
        is ({
          _is.UuidValue staffId,
          _is.UuidValue supervisorId,
          _is.UuidValue venueId,
        })) {
      return {
        "n": {
          "staffId": record.staffId.toJson(),
          "supervisorId": record.supervisorId.toJson(),
          "venueId": record.venueId.toJson(),
        },
      };
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }

  /// Maps container types (like [List], [Map], [Set]) containing
  /// [Record]s or non-String-keyed [Map]s to their JSON representation.
  ///
  /// It should not be called for [SerializableModel] types. These
  /// handle the "[Record] in container" mapping internally already.
  ///
  /// It is only supposed to be called from generated protocol code.
  ///
  /// Returns either a `List<dynamic>` (for List, Sets, and Maps with
  /// non-String keys) or a `Map<String, dynamic>` in case the input was
  /// a `Map<String, …>`.
  Object? mapContainerToJson(Object obj) {
    if (obj is! Iterable && obj is! Map) {
      throw ArgumentError.value(
        obj,
        'obj',
        'The object to serialize should be of type List, Map, or Set',
      );
    }

    dynamic mapIfNeeded(Object? obj) {
      return switch (obj) {
        Record record => mapRecordToJson(record),
        Iterable iterable => mapContainerToJson(iterable),
        Map map => mapContainerToJson(map),
        Object? value => value,
      };
    }

    switch (obj) {
      case Map<String, dynamic>():
        return {
          for (var entry in obj.entries) entry.key: mapIfNeeded(entry.value),
        };
      case Map():
        return [
          for (var entry in obj.entries)
            {
              'k': mapIfNeeded(entry.key),
              'v': mapIfNeeded(entry.value),
            },
        ];

      case Iterable():
        return [
          for (var e in obj) mapIfNeeded(e),
        ];
    }

    return obj;
  }
}

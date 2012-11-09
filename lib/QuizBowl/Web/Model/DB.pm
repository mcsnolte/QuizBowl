package QuizBowl::Web::Model::DB;

# ABSTRACT: Catalyst DBIC Schema Model

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'QuizBowl::Schema',
);

1;

